%w(survey survey_section question_group question dependency dependency_condition answer validation validation_condition).each {|model| require model }
require 'active_support' # for humanize
require 'fastercsv'
require 'csv'
module Surveyor
  class RedcapParser
    # Attributes
    attr_accessor :context

    # Class methods
    def self.parse(str, filename)
      puts
      Surveyor::RedcapParser.new.parse(str, filename)
      puts
      puts
    end
    
    # Instance methods
    def initialize
      self.context = {}
    end
    def parse(str, filename)
      csvlib = CSV.const_defined?(:Reader) ? FasterCSV : CSV
      begin
        csvlib.parse(str, :headers => :first_row, :return_headers => true, :header_converters => :symbol) do |r|
          if r.header_row? # header row
            return puts "Missing headers: #{missing_columns(r.headers).inspect}\n\n" unless missing_columns(r.headers).blank?
            context[:survey] = Survey.new(:title => filename)
            print "survey_#{context[:survey].access_code} "
          else # non-header rows
            SurveySection.build_or_set(context, r)
            Question.build_and_set(context, r)
            Answer.build_and_set(context, r)
            Validation.build_and_set(context, r)
            Dependency.build_and_set(context, r)
          end
        end
        print context[:survey].save ? "saved. " : " not saved! #{context[:survey].errors.each_full{|x| x }.join(", ")} "
        # print context[:survey].sections.map(&:questions).flatten.map(&:answers).flatten.map{|x| x.errors.each_full{|y| y}.join}.join
      rescue csvlib::MalformedCSVError
        puts = "Oops. Not a valid CSV file."
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
  end
end

# Surveyor models with extra parsing methods
class Survey < ActiveRecord::Base
end
class SurveySection < ActiveRecord::Base
  def self.build_or_set(context, r)
    unless context[:survey_section] && context[:survey_section].reference_identifier == r[:form_name]
      if match = context[:survey].sections.detect{|ss| ss.reference_identifier == r[:form_name]}
        context[:current_survey_section] = match
      else
        context[:survey_section] = context[:survey].sections.build({:title => r[:form_name].to_s.humanize, :reference_identifier => r[:form_name]})
        print "survey_section_#{context[:survey_section].reference_identifier} "
      end
    end
  end
end
class QuestionGroup < ActiveRecord::Base
end
class Question < ActiveRecord::Base
  def self.build_and_set(context, r)
    if !r[:section_header].blank?
      context[:survey_section].questions.build({:display_type => "label", :text => r[:section_header]})
      print "label_ "
    end
    context[:question] = context[:survey_section].questions.build({
      :reference_identifier => r[:variable__field_name],
      :text => r[:field_label],
      :help_text => r[:field_note],
      :is_mandatory => (/^y/i.match r[:required_field]) ? true : false,
      :pick => pick_from_field_type(r[:field_type]),
      :display_type => display_type_from_field_type(r[:field_type])
    })
    unless context[:question].reference_identifier.blank?
      context[:lookup] ||= []
      context[:lookup] << [context[:question].reference_identifier, nil, context[:question]]
    end    
    print "question_#{context[:question].reference_identifier} "
  end
  def self.pick_from_field_type(ft)
    {"checkbox" => :any, "radio" => :one}[ft] || :none
  end
  def self.display_type_from_field_type(ft)
    {"text" => :string, "dropdown" => :dropdown, "notes" => :text}[ft]
  end
end
class Dependency < ActiveRecord::Base
  def self.build_and_set(context, r)
    unless (bl = r[:branching_logic_show_field_only_if]).blank?
      # TODO: forgot to tie rule key to component, counting on the sequence of components
      letters = ('A'..'Z').to_a
      hash = decompose_rule(bl)
      context[:dependency] = context[:question].build_dependency(:rule => hash[:rule])
      hash[:components].each do |component|
        context[:dependency].dependency_conditions.build(decompose_component(component).merge(:lookup_reference => context[:lookup], :rule_key => letters.shift))
      end
      print "dependency(#{hash[:rule]}) "
    end
  end
  def self.decompose_component(str)
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
      puts "\n!!! skipping dependency_condition #{str}"
    end    
  end
  def self.decompose_rule(str)
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
class DependencyCondition < ActiveRecord::Base
  attr_accessor :question_reference, :answer_reference, :lookup_reference
  before_save :resolve_references
  def resolve_references
    return unless lookup_reference
    print "resolve(#{question_reference},#{answer_reference})"
    if answer_reference.blank? and (row = lookup_reference.find{|r| r[0] == question_reference and r[1] == nil}) and row[2].answers.size == 1
      print "...found "
      self.question = row[2]
      self.answer = self.question.answers.first
    elsif row = lookup_reference.find{|r| r[0] == question_reference and r[1] == answer_reference}    
      print "...found "
      self.answer = row[2]
      self.question = self.answer.question
    else
      puts "\n!!! failed lookup for dependency_condition q: #{question_reference} a: #{question_reference}"
    end
  end
end
class Answer < ActiveRecord::Base
  def self.build_and_set(context, r)
    case r[:field_type]
    when "text"
      context[:answer] = context[:question].answers.build(:response_class => "string", :text => "Text")
    when "notes"
      context[:answer] = context[:question].answers.build(:response_class => "text", :text => "Notes")
    when "file"
      puts "\n!!! skipping answer: file"
    end
    (r[:choices_or_calculations] || r[:choices_calculations_or_slider_labels]).to_s.split("|").each do |pair|
      aref, atext = pair.split(",").map(&:strip)
      if aref.blank? or atext.blank? or (aref.to_i.to_s != aref)
        puts "\n!!! skipping answer #{pair}"
      else
        context[:answer] = context[:question].answers.build(:reference_identifier => aref, :text => atext)
        unless context[:question].reference_identifier.blank? or aref.blank? or !context[:answer].valid?
          context[:lookup] ||= []
          context[:lookup] << [context[:question].reference_identifier, aref, context[:answer]]
        end
        puts "#{context[:answer].errors.full_messages}, #{context[:answer].inspect}" unless context[:answer].valid?
        print "answer_#{context[:answer].reference_identifier} "
      end
    end
  end
end
class Validation < ActiveRecord::Base
  def self.build_and_set(context, r)
    # text_validation_type text_validation_min text_validation_max
    min = r[:text_validation_min].to_s.blank? ? nil : r[:text_validation_min].to_s
    max = r[:text_validation_max].to_s.blank? ? nil : r[:text_validation_max].to_s
    type = r[:text_validation_type].to_s.blank? ? nil : r[:text_validation_type].to_s
    if min or max
      context[:question].answers.each do |a|
        context[:validation] = a.validations.build(:rule => min ? max ? "A and B" : "A" : "B")
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
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$")
        end
      when "integer"
        context[:question].display_type = :integer if context[:question].display_type == :string
        context[:question].answers.each do |a|
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "\d+")
        end
      when "number"
        context[:question].display_type = :float if context[:question].display_type == :string
        context[:question].answers.each do |a|
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "^\d*(,\d{3})*(\.\d*)?$")
        end
      when "phone"
        context[:question].answers.each do |a|
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp => "\d{3}.*\d{4}")
        end
      end
    end
  end
  
end
class ValidationCondition < ActiveRecord::Base
end
