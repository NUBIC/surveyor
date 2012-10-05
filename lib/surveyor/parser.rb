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
          Surveyor::Parser.rake_trace "\n"
          Surveyor::Parser.rake_trace context[:survey].save ? "saved. " : " not saved! #{context[type.to_sym].errors.each_full{|x| x }.join(", ")} "
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
  end
end

# Surveyor models with extra parsing methods

# Survey model
module SurveyorParserSurveyMethods
  # def SurveyorParserSurveyMethods.extended(obj)
  #   attr_accessor :context_reference
  #   attr_accessible :context_reference
  #   after_save :report_lost_and_duplicate_references
  # end
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    clear(context)

    # build and set context
    title = args[0]
    self.attributes = ({
      :title => title,
      :context_reference => context,
      :reference_identifier => reference_identifier }.merge(args[1] || {}))
    context[:survey] = self
  end
  def clear(context)
    context.delete_if{|k,v| true }
    context[:question_references] = {}
    context[:answer_references] = {}
    context[:bad_references] = []
    context[:duplicate_references] = []
  end
  def report_lost_and_duplicate_references
    raise Surveyor::ParserError, "Bad references: #{context_reference[:bad_references].join("; ")}" unless context_reference[:bad_references].empty?
    raise Surveyor::ParserError, "Duplicate references: #{context_reference[:duplicate_references].join("; ")}" unless context_reference[:duplicate_references].empty?
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
    context.delete_if{|k,v| !%w(survey question_references answer_references bad_references duplicate_references).map(&:to_sym).include?(k)}
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
    context.delete_if{|k,v| !%w(survey survey_section question_references answer_references bad_references duplicate_references).map(&:to_sym).include?(k)}
  end
end

# Question model
module SurveyorParserQuestionMethods
  # def SurveyorParserQuestionMethods.extended(obj)
  #   attr_accessor :correct, :context_reference
  #   attr_accessible :correct, :context_reference
  #   before_save :resolve_correct_answers
  # end
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| %w(question dependency dependency_condition answer validation validation_condition).map(&:to_sym).include? k}

    # build and set context
    text = args[0] || "Question"
    self.attributes = ({
      :context_reference => context,
      :question_group => context[:question_group],
      :reference_identifier => reference_identifier,
      :text => text,
      :display_type => (original_method =~ /label|image/ ? original_method : "default"),
      :display_order => context[:survey_section].questions.size }.merge(args[1] || {}))
    context[:survey_section].questions << context[:question] = self

    # keep reference for dependencies
    unless reference_identifier.blank?
      context[:duplicate_references].push "q_#{reference_identifier}" if context[:question_references].has_key?(reference_identifier)
      context[:question_references][reference_identifier] = context[:question]
    end

    # add grid answers
    if context[:question_group] && context[:question_group].display_type == "grid"
      (context[:grid_answers] || []).each do |grid_answer|
        a = context[:question].answers.build(grid_answer.attributes.reject{|k,v| %w(id api_id created_at updated_at).include?(k)})
        context[:answer_references][reference_identifier] ||= {} unless reference_identifier.blank?
        context[:answer_references][reference_identifier][grid_answer.reference_identifier] = a unless reference_identifier.blank? or grid_answer.reference_identifier.blank?
      end
    end
  end

  def resolve_correct_answers
    unless self.correct.blank? or self.reference_identifier.blank? or self.context_reference.blank?
      # Looking up references for quiz answers
      self.context_reference[:answer_references][self.reference_identifier] ||= {}
      self.context_reference[:answer_references][self.reference_identifier][correct].save
      Surveyor::Parser.rake_trace( (self.correct_answer_id = self.context_reference[:answer_references][self.reference_identifier][self.correct].id) ? "found correct answer:#{self.correct} " : "lost! correct answer:#{self.correct} ")
    end
  end
end

# Dependency model
module SurveyorParserDependencyMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| %w(dependency dependency_condition).map(&:to_sym).include? k}

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
  # def SurveyorParserDependencyConditionMethods.extended(obj)
  #   attr_accessor :question_reference, :answer_reference, :context_reference
  #   attr_accessible :question_reference, :answer_reference, :context_reference
  #   before_save :resolve_references
  # end
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| k == :dependency_condition}

    # build and set context
    a0, a1, a2 = args
    self.attributes = ({
      :context_reference => context,
      :operator => a1 || "==",
      :question_reference => a0.to_s.gsub(/^q_/, ""),
      :rule_key => reference_identifier
    }.merge( a2.is_a?(Hash) ? a2 : { :answer_reference => a2.to_s.gsub(/^a_/, "") }))
    context[:dependency].dependency_conditions << context[:dependency_condition] = self
  end

  def resolve_references
    if context_reference
      # Looking up references to questions and answers for linking the dependency objects
      if (self.question = context_reference[:question_references][question_reference])
        Surveyor::Parser.rake_trace("found q_#{question_reference} ")
      else
        Surveyor::Parser.rake_trace("lost q_#{question_reference}! ")
        context_reference[:bad_references].push "q_#{question_reference}"
      end
      unless answer_reference.blank?
        context_reference[:answer_references][question_reference] ||= {}
        if (self.answer = context_reference[:answer_references][question_reference][answer_reference])
          Surveyor::Parser.rake_trace( "found a_#{answer_reference} ")
        else
          Surveyor::Parser.rake_trace( "lost a_#{answer_reference}!")
          context_reference[:bad_references].push "q_#{question_reference}, a_#{answer_reference}"
        end
      end
    end
  end
end

# Answer model
module SurveyorParserAnswerMethods
  def parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| %w(answer validation validation_condition reference_identifier).map(&:to_sym).include? k}
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
    context.delete_if{|k,v| k == :validation_condition}

    # build and set context
    a0, a1 = args
    self.attributes = ({
      :operator => a0 || "==",
      :rule_key => reference_identifier}.merge(a1 || {}))
    context[:validation].validation_conditions << context[:validation_condition] = self
  end
end