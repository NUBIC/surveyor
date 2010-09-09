module Surveyor
  class Parser
    # Attributes
    attr_accessor :context

    # Class methods
    def self.parse(str)
      Surveyor::Parser.new.instance_eval(str)
      puts
    end

    # Instance methods
    def initialize
      self.context = {}
    end
    
    # This method_missing does all the heavy lifting for the DSL
    def method_missing(missing_method, *args, &block)
      method_name, reference_identifier = missing_method.to_s.split("_", 2)
      type = full(method_name)
      
      print "#{type}"
      
      # check for blocks
      raise "Error: A #{type.humanize} cannot be empty" if block_models.include?(type) && !block_given?
      raise "Error: Dropping the #{type.humanize} block like it's hot!" if !block_models.include?(type) && block_given?
      
      # parse and build
      type.classify.constantize.parse_and_build(context, args, method_name, reference_identifier)
      
      # save
      print context[type.to_sym].save ? ". " : " not saved! #{context[type.to_sym].errors.each_full.join(", ")} "

      # evaluate and clear context for block models
      if block_models.include?(type)
        self.instance_eval(&block) 
        # if type == 'survey'
        #   puts
        #   puts context[type.to_sym].save ? "saved" : "not saved!"
        # end
        context[type.to_sym].clear(context)
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
      when /^c(ondition)?$/; context["validation"] ? "validation_condition" : "dependency_condition"
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
class Survey < ActiveRecord::Base
  # block
  include Surveyor::Models::SurveyMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| true}
    
    # build and set context
    title = args[0]
    context[:survey] = new({  :title => title, 
                              :access_code => Surveyor::Common.normalize(title),
                              :reference_identifier => reference_identifier}.merge(args[1] || {}))
  end
  def clear(context)
    context.delete_if{|k,v| true}
  end
end
class SurveySection < ActiveRecord::Base
  # block
  include Surveyor::Models::SurveySectionMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| k != :survey}
    
    # build and set context
    title = args[0]
    context[:survey_section] = new({  :survey => context[:survey], 
                                      :title => title, 
                                      :data_export_identifier => Surveyor::Common.normalize(title)}.merge(args[1] || {}))
  end
  def clear(context)
    context.delete_if{|k,v| k != :survey}
  end
end
class QuestionGroup < ActiveRecord::Base
  # block
  include Surveyor::Models::QuestionGroupMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| k != :survey && k != :survey_section}
    
    # build and set context
    context[:question_group] = new({  :text => args[0] || "Question Group", 
                                      :display_type => (original_method =~ /grid|repeater/ ? original_method : "default")}.merge(args[1] || {}))

  end
  def clear(context)
    context.delete_if{|k,v| k != :survey && k != :survey_section}
  end
end
class Question < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::QuestionMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| %w(question dependency dependency_condition answer validation validation_condition).map(&:to_sym).include? k}
    
    # build and set context
    text = args[0] || "Question"
    context[:question] = new({  :survey_section => context[:survey_section],
                                :question_group => context[:question_group],
                                :reference_identifier => reference_identifier,
                                :text => text,
                                :short_text => text, 
                                :display_type => (original_method =~ /label|image/ ? original_method : "default"),
                                :data_export_identifier => Surveyor::Common.normalize(text)}.merge(args[1] || {}))

    # add grid answers
    context[:question].answers = (context[:grid_answers] || []).dup if context[:question_group] && context[:question_group].display_type == :grid
  end
end
class Dependency < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::DependencyMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| %w(dependency dependency_condition).map(&:to_sym).include? k}
    
    # build and set context
    context[:dependency] = new({  :question => context[:question],
                                  :question_group => context[:question_group]}.merge(args[0] || {}))
  end
end
class DependencyCondition < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::DependencyConditionMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| k == :dependency_condition}
    
    # build and set context
    a0, a1, a2 = args
    context[:dependency_condition] = new({  :dependency => context[:dependency],
                                            :operator => a1 || "==",
                                            :question_reference => a0.to_s.gsub("q_", ""),
                                            :rule_key => reference_identifier}.merge(a2.is_a?(Hash) ? a2 : {:answer_reference => a2.to_s.gsub("a_", "")}))
  end
end
class Answer < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::AnswerMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| %w(answer validation validation_condition).map(&:to_sym).include? k}

    # build and set context
    context[:answer] = new({  :question => context[:question],
                              :is_exclusive => false,
                              :hide_label => false,
                              :response_class => "answer",
                              :display_order => context[:question] ? context[:question].answers.count : context[:grid_answers] ? context[:grid_answers].count : 0}.merge(self.parse_args(args)))
    
    # add answers to grid
    if context[:question_group] && context[:question_group].display_type == :grid
      context[:grid_answers] ||= []
      context[:grid_answers] << context[:answer]
    end
  end
  def self.parse_args(args)
    case args[0]
    when Hash # Hash
      self.text_args(args[0][:text]).merge(args[0])
    when String # (String, Hash) or (String, Symbol, Hash)
      self.text_args(args[0]).merge(self.hash_from args[1]).merge(args[2] || {})
    when Symbol # (Symbol, Hash) or (Symbol, Symbol, Hash)
      self.symbol_args(args[0]).merge(self.hash_from args[1]).merge(args[2] || {})
    else
      self.text_args(nil)
    end
  end
  def self.text_args(text = "Answer")
    {:text => text.to_s, :short_text => text, :data_export_identifier => Surveyor::Common.normalize(text)}
  end
  def self.hash_from(arg)
    arg.is_a?(Symbol) ? {:response_class => arg.to_s} : arg.is_a?(Hash) ? arg : {}
  end
  def self.symbol_args(arg)
    case arg
    when :other
      self.text_args("Other")
    when :other_and_string
      self.text_args("Other").merge({:response_class => "string"})
    when :none, :omit # is_exclusive erases and disables other checkboxes and input elements
      self.text_args(arg.to_s.humanize).merge({:is_exclusive => true})
    when :integer, :date, :time, :datetime, :text, :datetime, :string
      self.text_args(arg.to_s.humanize).merge({:response_class => arg.to_s, :hide_label => true})
    end
  end
end
class Validation < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::ValidationMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| %w(validation validation_condition).map(&:to_sym).include? k}

    # build and set context
    context[:validation] = new({  :answer => context[:answer],
                                  :rule => "A"}.merge(args[0] || {}))
  end
end
class ValidationCondition < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::ValidationConditionMethods
  
  def self.parse_and_build(context, args, original_method, reference_identifier)
    # clear context
    context.delete_if{|k,v| k == :validation_condition}

    # build and set context
    a0, a1 = args
    context[:dependency_condition] = new({  :validation => context[:validation],
                                            :operator => a0 || "==",
                                            :rule_key => reference_identifier}.merge(a1 || {}))
  end
end
