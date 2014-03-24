%w(survey survey_section question_group question dependency dependency_condition answer validation validation_condition).each {|model| require model }
require 'active_support' # for humanize
module Surveyor
  class RedcapParserError < StandardError; end
  class RedcapParser
    class << self; attr_accessor :options end

    # Attributes
    attr_accessor :context

    # Class methods
    def self.parse(str, filename, options={})
      self.options = options
      Surveyor::RedcapParser.rake_trace "\n"
      Surveyor::RedcapParser.new.parse(str, filename)
      Surveyor::RedcapParser.rake_trace "\n"
    end
    def self.rake_trace(str)
      self.options ||= {}
      print str if self.options[:trace] == true
    end

    # Instance methods
    def initialize
      self.context = {}
      self.context[:dependency_conditions] = []
    end
    def parse(str, filename)
      csvlib = Surveyor::Common.csv_impl
      begin
        csvlib.parse(str, :headers => :first_row, :return_headers => true, :header_converters => :symbol) do |r|
          if r.header_row? # header row
            return Surveyor::RedcapParser.rake_trace "Missing headers: #{missing_columns(r.headers).inspect}\n\n" unless missing_columns(r.headers).blank?
            context[:survey] = Survey.new(:title => filename)
            Surveyor::RedcapParser.rake_trace "survey_#{context[:survey].access_code} "
          else # non-header rows
            SurveySection.new.extend(SurveyorRedcapParserSurveySectionMethods).build_or_set(context, r)
            Question.new.extend(SurveyorRedcapParserQuestionMethods).build_and_set(context, r)
            Answer.new.extend(SurveyorRedcapParserAnswerMethods).build_and_set(context, r)
            Validation.new.extend(SurveyorRedcapParserValidationMethods).build_and_set(context, r)
            Dependency.new.extend(SurveyorRedcapParserDependencyMethods).build_and_set(context, r)
          end
        end
        resolve_references
        Surveyor::RedcapParser.rake_trace context[:survey].save ? "saved. " : " not saved! #{context[:survey].errors.full_messages.join(", ")} "
        # Surveyor::RedcapParser.rake_trace context[:survey].sections.map(&:questions).flatten.map(&:answers).flatten.map{|x| x.errors.each_full{|y| y}.join}.join
      rescue csvlib::MalformedCSVError
        raise Surveyor::RedcapParserError, "Oops. Not a valid CSV file."
      # ensure
      end
      return context[:survey]
    end
    def missing_columns(r)
      missing = []
      missing << "choices_or_calculations" unless r.map(&:to_s).include?("choices_or_calculations") or r.map(&:to_s).include?("choices_calculations_or_slider_labels")
      missing << "text_validation_type" unless r.map(&:to_s).include?("text_validation_type") or r.map(&:to_s).include?("text_validation_type_or_show_slider_number")
      missing += (static_required_columns - r.map(&:to_s))
    end
    def static_required_columns
      # no longer requiring field_units
      %w(variable__field_name form_name section_header field_type field_label field_note text_validation_min text_validation_max identifier branching_logic_show_field_only_if required_field)
    end
    def resolve_references
      context[:dependency_conditions].each do |dc|
        Surveyor::RedcapParser.rake_trace "resolve(#{dc.question_reference},#{dc.answer_reference})"
        if dc.answer_reference.blank? and (context[:question_references][dc.question_reference].answers.size == 1)
          Surveyor::RedcapParser.rake_trace "...found "
          dc.question = context[:question_references][dc.question_reference]
          dc.answer = dc.question.answers.first
        elsif answer = context[:answer_references][dc.question_reference][dc.answer_reference]
          Surveyor::RedcapParser.rake_trace "...found "
          dc.answer = answer
          dc.question = context[:question_references][dc.question_reference]
        else
          Surveyor::RedcapParser.rake_trace "\n!!! failed lookup for dependency_condition q: #{question_reference} a: #{question_reference}"
        end
      end
    end
  end
end

# Surveyor models with extra parsing methods

# SurveySection model
module SurveyorRedcapParserSurveySectionMethods
  def build_or_set(context, r)
    unless context[:survey_section] && context[:survey_section].reference_identifier == r[:form_name]
      if match = context[:survey].sections.detect{|ss| ss.reference_identifier == r[:form_name]}
        context[:current_survey_section] = match
      else
        self.attributes = (
          {:title => r[:form_name].to_s.humanize,
          :reference_identifier => r[:form_name],
          :display_order => context[:survey].sections.size })
        context[:survey].sections << context[:survey_section] = self
        Surveyor::RedcapParser.rake_trace "survey_section_#{context[:survey_section].reference_identifier} "
      end
    end
  end
end

# Question model
module SurveyorRedcapParserQuestionMethods
  def build_and_set(context, r)
    if !r[:section_header].blank?
      context[:survey_section].questions.build({:display_type => "label", :text => r[:section_header], :display_order => context[:survey_section].questions.size})
      Surveyor::RedcapParser.rake_trace "label_ "
    end
    self.attributes = ({
      :reference_identifier => r[:variable__field_name],
      :text => r[:field_label],
      :help_text => r[:field_note],
      :is_mandatory => (/^y/i.match r[:required_field]) ? true : false,
      :pick => pick_from_field_type(r[:field_type]),
      :display_type => display_type_from_field_type(r[:field_type]),
      :display_order => context[:survey_section].questions.size
    })
    context[:survey_section].questions << context[:question] = self
    unless context[:question].reference_identifier.blank?
      context[:question_references] ||= {}
      context[:question_references][context[:question].reference_identifier] = context[:question]
    end
    Surveyor::RedcapParser.rake_trace "question_#{context[:question].reference_identifier} "
  end
  def pick_from_field_type(ft)
    {"checkbox" => :any, "radio" => :one}[ft] || :none
  end
  def display_type_from_field_type(ft)
    {"text" => :string, "dropdown" => :dropdown, "notes" => :text}[ft]
  end
end

# Dependency model
module SurveyorRedcapParserDependencyMethods
  def build_and_set(context, r)
    unless (bl = r[:branching_logic_show_field_only_if]).blank?
      # TODO: forgot to tie rule key to component, counting on the sequence of components
      letters = ('A'..'Z').to_a
      hash = decompose_rule(bl)
      self.attributes = {:rule => hash[:rule]}
      context[:question].dependency = context[:dependency] = self
      hash[:components].each do |component|
        dc = context[:dependency].dependency_conditions.build(decompose_component(component).merge({ :rule_key => letters.shift } ))
        context[:dependency_conditions] << dc
      end
      Surveyor::RedcapParser.rake_trace "dependency(#{hash[:rule]}) "
    end
  end
  def decompose_component(str)
    # [initial_52] = "1" or [f1_q15] = '' or [f1_q15] = '-2' or [hi_event1_type] <> ''
    if match = str.match(/^\[(\w+)\] ?([!=><]+) ?['"](-?\w*)['"]$/)
      {:question_reference => match[1], :operator => match[2].gsub(/^=$/, "==").gsub(/^<>$/, "!="), :answer_reference => match[3]}
    # [initial_119(2)] = "1" or [hiprep_heat2(97)] = '1'
    elsif match = str.match(/^\[(\w+)\((\w+)\)\] ?([!=><]+) ?['"]1['"]$/)
      {:question_reference => match[1], :operator => match[3].gsub(/^=$/, "==").gsub(/^<>$/, "!="), :answer_reference => match[2]}
    # [f1_q15] >= 21 or [f1_q15] >= -21
    elsif match = str.match(/^\[(\w+)\] ?([!=><]+) ?(-?\d+)$/)
      {:question_reference => match[1], :operator => match[2].gsub(/^=$/, "==").gsub(/^<>$/, "!="), :integer_value => match[3]}
    else
      Surveyor::RedcapParser.rake_trace "\n!!! skipping dependency_condition #{str}"
    end
  end
  def decompose_rule(str)
    # see spec/lib/redcap_parser_spec.rb for examples
    letters = ('A'..'Z').to_a
    rule = str
    components = str.split(/\band\b|\bor\b|\((?!\d)|\)(?!\(|\])/).reject(&:blank?).map(&:strip)
    components.each_with_index do |part, i|
      # internal commas on the right side of the operator e.g. '[initial_189] = "1, 2, 3"'
      if match = part.match(/^(\[[^\]]+\][^\"]+)"([0-9 ]+,[0-9 ,]+)"$/)
        nums = match[2].split(",").map(&:strip)
        components[i] = nums.map{|x| "#{match[1]}\"#{x}\""}
        # sub in rule key
        rule = rule.gsub(part, "(#{nums.map{letters.shift}.join(' and ')})")
      # multiple internal parenthesis on the left  e.g. '[initial_119(1)(2)(3)(4)(6)] = "1"'
      elsif match = part.match(/^\[(\w+)(\(\d+\)\([\d\(\)]+)\]([^\"]+"\d+")$/)
        nums = match[2].split(/\(|\)/).reject(&:blank?).map(&:strip)
        components[i] = nums.map{|x| "[#{match[1]}(#{x})]#{match[3]}"}
        # sub in rule key
        rule = rule.gsub(part, "(#{nums.map{letters.shift}.join(' and ')})")
      else
        # 'or' on the right of the operator
        components[i] = components[i-1].gsub(/"(\d+)"/, part) if part.match(/^"(\d+)"$/) && i != 0
        # sub in rule key
        rule = rule.gsub(part){letters.shift}
      end
    end
    {:rule => rule, :components => components.flatten}
  end
end

# DependencyCondition model
module SurveyorRedcapParserDependencyConditionMethods
  DependencyCondition.instance_eval do
    attr_accessor :question_reference, :answer_reference
  end
end

# Answer model
module SurveyorRedcapParserAnswerMethods
  def build_and_set(context, r)
    case r[:field_type]
    when "text"
      self.attributes = {
        :response_class => "string",
        :text => "Text",
        :display_order => context[:question].answers.size }
      context[:question].answers << context[:answer] = self
    when "notes"
      self.attributes = {
        :response_class => "text",
        :text => "Notes",
        :display_order => context[:question].answers.size }
      context[:question].answers << context[:answer] = self
    when "file"
      Surveyor::RedcapParser.rake_trace "\n!!! skipping answer: file"
    end
    (r[:choices_or_calculations] || r[:choices_calculations_or_slider_labels]).to_s.split("|").each do |pair|
      aref, atext = pair.split(",").map(&:strip)
      if aref.blank? or atext.blank? or (aref.to_i.to_s != aref)
        Surveyor::RedcapParser.rake_trace "\n!!! skipping answer #{pair}"
      else
        a = Answer.new({
          :reference_identifier => aref,
          :text => atext,
          :display_order => context[:question].answers.size })
        context[:question].answers << context[:answer] = a
        unless context[:question].reference_identifier.blank? or aref.blank? or !context[:answer].valid?
          context[:answer_references] ||= {}
          context[:answer_references][context[:question].reference_identifier] ||= {}
          context[:answer_references][context[:question].reference_identifier][aref] = context[:answer]
        end
        Surveyor::RedcapParser.rake_trace "#{context[:answer].errors.full_messages}, #{context[:answer].inspect}" unless context[:answer].valid?
        Surveyor::RedcapParser.rake_trace "answer_#{context[:answer].reference_identifier} "
      end
    end
  end
end

# Validation model
module SurveyorRedcapParserValidationMethods
  def build_and_set(context, r)
    # text_validation_type text_validation_min text_validation_max
    min = r[:text_validation_min].to_s.blank? ? nil : r[:text_validation_min].to_s
    max = r[:text_validation_max].to_s.blank? ? nil : r[:text_validation_max].to_s
    type = r[:text_validation_type].to_s.blank? ? nil : r[:text_validation_type].to_s
    if min or max
      context[:question].answers.each do |a|
        self.rule = (min ? max ? "A and B" : "A" : "B")
        a.validations << context[:validation] = self
        context[:validation].validation_conditions.build(:rule_key => "A", :operator => ">=", :integer_value => min) if min
        context[:validation].validation_conditions.build(:rule_key => "B", :operator => "<=", :integer_value => max) if max
      end
    elsif type
      # date email integer number phone
      case r[:text_validation_type]
      when "date"
        context[:question].display_type = :date if context[:question].display_type == :string
      when "email"
        context[:question].answers.each do |a|
          self.rule = "A"
          a.validations << context[:validation] = self
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$")
        end
      when "integer"
        context[:question].display_type = :integer if context[:question].display_type == :string
        context[:question].answers.each do |a|
          self.rule = "A"
          a.validations << context[:validation] = self
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "\d+")
        end
      when "number"
        context[:question].display_type = :float if context[:question].display_type == :string
        context[:question].answers.each do |a|
          self.rule = "A"
          a.validations << context[:validation] = self
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "^\d*(,\d{3})*(\.\d*)?$")
        end
      when "phone"
        context[:question].answers.each do |a|
                    self.rule = "A"
          a.validations << context[:validation] = self
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "\d{3}.*\d{4}")
        end
      end
    end
  end
end
