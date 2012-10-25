%w(survey survey_section question_group question dependency dependency_condition answer validation validation_condition).each {|model| require model }
module Surveyor
  class ParserError < StandardError; end
  class Parser
    class << self; attr_accessor :options end

    # Attributes
    attr_accessor :context

    # Class methods
    def self.parse(str, options={})
      self.options = options
      Surveyor::Parser.rake_trace "\n"
      Surveyor::Parser.new.parse(str)
      Surveyor::Parser.rake_trace "\n"
    end
    def self.rake_trace(str)
      self.options ||= {}
      print str if self.options[:trace] == true
    end

    # Instance methods
    def initialize
      self.context = {}
    end
    def parse(str)
      instance_eval(str)
      return context[:survey]
    end
    # This method_missing does all the heavy lifting for the DSL
    def method_missing(missing_method, *args, &block)
      method_name, reference_identifier = missing_method.to_s.split("_", 2)
      type = full(method_name)

      Surveyor::Parser.rake_trace reference_identifier.blank? ? "#{type} " : "#{type}_#{reference_identifier} "

      # check for blocks
      raise Surveyor::ParserError, "Error: A #{type.humanize} cannot be empty" if block_models.include?(type) && !block_given?
      raise Surveyor::ParserError, "Error: Dropping the #{type.humanize} block like it's hot!" if !block_models.include?(type) && block_given?

      # parse and build
      type.classify.constantize.new.extend("SurveyorParser#{type.classify}Methods".constantize).parse_and_build(context, args, method_name, reference_identifier)

      # evaluate and clear context for block models
      if block_models.include?(type)
        self.instance_eval(&block)
        if type == 'survey'
          resolve_dependency_condition_references
          resolve_question_correct_answers
          report_lost_and_duplicate_references
          if context[:survey].save
            Surveyor::Parser.rake_trace "\nsaved."
          else
            raise Surveyor::ParserError, "Survey not saved: #{context[:survey].errors.full_messages.join(", ")}"
          end
        else
          context[type.to_sym].clear(context)
        end
      end
    end

    # Private methods
    private

    def full(method_name)
      case method_name.to_s
      when /^section$/; "survey_section"
      when /^g|grid|group|repeater$/; "question_group"
      when /^q|label|image$/; "question"
      when /^a$/; "answer"
      when /^d$/; "dependency"
      when /^c(ondition)?$/; context[:validation] ? "validation_condition" : "dependency_condition"
      when /^v$/; "validation"
      when /^dc(ondition)?$/; "dependency_condition"
      when /^vc(ondition)?$/; "validation_condition"
      else method_name
      end
    end
    def block_models
      %w(survey survey_section question_group)
    end
    def report_lost_and_duplicate_references
      raise Surveyor::ParserError, "Bad references: #{self.context[:bad_references].join("; ")}" unless self.context[:bad_references].empty?
      raise Surveyor::ParserError, "Duplicate references: #{self.context[:duplicate_references].join("; ")}" unless self.context[:duplicate_references].empty?
    end
    def resolve_question_correct_answers
      self.context[:questions_with_correct_answers].each do |question_reference_idenitifer, correct_answer_reference|
        # Looking up references for quiz answers
        if self.context[:answer_references][question_reference_idenitifer] &&
             (a = self.context[:answer_references][question_reference_idenitifer][correct_answer_reference]) &&
             a.save
          self.context[:question_references][question_reference_idenitifer].correct_answer_id = a.id
        else
          self.context[:bad_references].push "q_#{question_reference_idenitifer}.correct => a_#{correct_answer_reference}"
        end
      end
    end
    def resolve_dependency_condition_references
      self.context[:dependency_conditions].each do |dc|
        # Looking up references to questions and answers for linking the dependency objects
        self.context[:bad_references].push "q_#{dc.question_reference}" unless (dc.question = self.context[:question_references][dc.question_reference])
        self.context[:answer_references][dc.question_reference] ||= {}
        self.context[:bad_references].push "q_#{dc.question_reference}, a_#{dc.answer_reference}" if !dc.answer_reference.blank? and (dc.answer = self.context[:answer_references][dc.question_reference][dc.answer_reference]).nil?
      end
    end
  end
end

# Surveyor models with extra parsing methods

# Survey model
module SurveyorParserSurveyMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    clear(context)

    # build and set context
    title = args[0]
    self.attributes = ({
      :title => title,
      :reference_identifier => reference_identifier }.merge(args[1] || {}))
    context[:survey] = self
  end
  def clear(context)
    context.delete_if{|k,v| true}
    context.merge!({
      :question_references => {},
      :answer_references => {},
      :bad_references => [],
      :duplicate_references => [],
      :dependency_conditions => [],
      :questions_with_correct_answers => {} })
  end
end

# SurveySection model
module SurveyorParserSurveySectionMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    clear(context)

    # build and set context
    title = args[0]
    self.attributes = ({
      :title => title,
      :display_order => context[:survey].sections.size }.merge(args[1] || {}))
    context[:survey].sections << context[:survey_section] = self
  end
  def clear(context)
    [ :survey_section,
      :question_group,
      :question,
      :dependency,
      :dependency_condition,
      :answer,
      :validation,
      :validation_condition ].each{|k| context.delete k}
  end
end

# QuestionGroup model
module SurveyorParserQuestionGroupMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    clear(context)

    # build and set context
    self.attributes = ({
      :text => args[0] || "Question Group",
      :display_type => (original_method =~ /grid|repeater/ ? original_method : "default")}.merge(args[1] || {}))
    context[:question_group] = self
  end
  def clear(context)
    [ :question_group,
      :grid_answers,
      :question,
      :dependency,
      :dependency_condition,
      :answer,
      :validation,
      :validation_condition ].each{|k| context.delete k}
  end
end

# Question model
module SurveyorParserQuestionMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    [ :question,
      :dependency,
      :dependency_condition,
      :answer,
      :validation,
      :validation_condition ].each{|k| context.delete k}

    # build and set context
    text = args[0] || "Question"
    hash_args = args[1] || {}
    correct = hash_args.delete :correct
    self.attributes = ({
      :question_group => context[:question_group],
      :reference_identifier => reference_identifier,
      :text => text,
      :display_type => (original_method =~ /label|image/ ? original_method : "default"),
      :display_order => context[:survey_section].questions.size }.merge(hash_args))
    context[:survey_section].questions << context[:question] = self

    # keep reference for correct answers
    context[:questions_with_correct_answers][self.reference_identifier] = correct unless self.reference_identifier.blank? or correct.blank?

    # keep reference for dependencies
    unless self.reference_identifier.blank?
      context[:duplicate_references].push "q_#{self.reference_identifier}" if context[:question_references].has_key?(self.reference_identifier)
      context[:question_references][self.reference_identifier] = context[:question]
    end

    # add grid answers
    if context[:question_group] && context[:question_group].display_type == "grid"
      (context[:grid_answers] || []).each do |grid_answer|
        a = context[:question].answers.build(grid_answer.attributes.reject{|k,v| %w(id api_id created_at updated_at).include?(k)})
        context[:answer_references][self.reference_identifier] ||= {} unless self.reference_identifier.blank?
        context[:answer_references][self.reference_identifier][grid_answer.reference_identifier] = a unless self.reference_identifier.blank? or grid_answer.reference_identifier.blank?
      end
    end
  end
end

# Dependency model
module SurveyorParserDependencyMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    [ :dependency,
      :dependency_condition ].each{|k| context.delete k}

    # build and set context
    self.attributes = (args[0] || {})
    if context[:question]
      context[:dependency] = context[:question].dependency = self
    elsif context[:question_group]
      context[:dependency] = context[:question_group].dependency = self
    end
  end
end

# DependencyCondition model
module SurveyorParserDependencyConditionMethods
  DependencyCondition.instance_eval do
    attr_accessor :question_reference, :answer_reference
    attr_accessible :question_reference, :answer_reference
  end
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete :dependency_condition

    # build and set context
    a0, a1, a2 = args
    self.attributes = ({
      :operator => a1 || "==",
      :question_reference => a0.to_s.gsub(/^q_/, ""),
      :rule_key => reference_identifier
    }.merge( a2.is_a?(Hash) ? a2 : { :answer_reference => a2.to_s.gsub(/^a_/, "") }))
    context[:dependency].dependency_conditions << context[:dependency_condition] = self
    context[:dependency_conditions] << self
  end
end

# Answer model
module SurveyorParserAnswerMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    [ :answer,
      :validation,
      :validation_condition ].each{|k| context.delete k}
    attrs = { :reference_identifier => reference_identifier }.merge(parse_args(args))

    # add answers to grid
    if context[:question_group] && context[:question_group].display_type == "grid"
      context[:grid_answers] ||= []
      self.attributes = ({:display_order => [:grid_answers].size}.merge(attrs))
      context[:grid_answers] << context[:answer] = self
    else
      self.attributes = ({:display_order => context[:question].answers.size}.merge(attrs))
      context[:question].answers << context[:answer] = self
      # keep reference for dependencies
      unless context[:question].reference_identifier.blank? or reference_identifier.blank?
        context[:answer_references][context[:question].reference_identifier] ||= {}
        context[:duplicate_references].push "q_#{context[:question].reference_identifier}, a_#{reference_identifier}" if context[:answer_references][context[:question].reference_identifier].has_key?(reference_identifier)
        context[:answer_references][context[:question].reference_identifier][reference_identifier] = context[:answer]
      end
    end
  end
  def parse_args(args)
    case args[0]
    when Hash # Hash
      text_args(args[0][:text]).merge(args[0])
    when String # (String, Hash) or (String, Symbol, Hash)
      text_args(args[0]).merge(hash_from args[1]).merge(args[2] || {})
    when Symbol # (Symbol, Hash) or (Symbol, Symbol, Hash)
      symbol_args(args[0]).merge(hash_from args[1]).merge(args[2] || {})
    else
      text_args(nil)
    end
  end
  def text_args(text = "Answer")
    {:text => text.to_s}
  end
  def hash_from(arg)
    arg.is_a?(Symbol) ? {:response_class => arg.to_s} : arg.is_a?(Hash) ? arg : {}
  end
  def symbol_args(arg)
    case arg
    when :other
      text_args("Other")
    when :other_and_string
      text_args("Other").merge({:response_class => "string"})
    when :none, :omit # is_exclusive erases and disables other checkboxes and input elements
      text_args(arg.to_s.humanize).merge({:is_exclusive => true})
    when :integer, :float, :date, :time, :datetime, :text, :datetime, :string
      text_args(arg.to_s.humanize).merge({:response_class => arg.to_s, :display_type => "hidden_label"})
    end
  end
end

# Validation model
module SurveyorParserValidationMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    [ :validation,
      :validation_condition ].each{|k| context.delete k}

    context.delete_if{|k,v| %w(validation validation_condition).map(&:to_sym).include? k}

    # build and set context
    self.attributes = ({:rule => "A"}.merge(args[0] || {}))
    context[:answer].validations << context[:validation] = self
  end
end

# ValidationCondition model
module SurveyorParserValidationConditionMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete :validation_condition

    # build and set context
    a0, a1 = args
    self.attributes = ({
      :operator => a0 || "==",
      :rule_key => reference_identifier}.merge(a1 || {}))
    context[:validation].validation_conditions << context[:validation_condition] = self
  end
end
