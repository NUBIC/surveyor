require File.dirname(__FILE__) + '/question_group'
require File.dirname(__FILE__) + '/question'
require File.dirname(__FILE__) + '/answer'
require File.dirname(__FILE__) + '/dependency'
require File.dirname(__FILE__) + '/dependency_condition'
require File.dirname(__FILE__) + '/columnizer'
require 'activesupport'
#require 'activesupport/lib/active_support/core_ext/string/inflections'

class SurveySection
  include Columnizer

  # Context, Content, Display, Reference, Children, Placeholders
  attr_accessor :id, :parser, :survey_id
  attr_accessor :title, :description
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :display_order, :custom_class
  attr_accessor :question_groups, :questions, :grid_answers
  attr_accessor :current_question_group, :current_question, :current_dependency

  # id, survey, and title required
  def initialize(id, survey, title, options = {})
    self.id = id
    self.survey_id = survey.id
    self.parser = survey.parser
    self.title = title.strip
    self.questions = []
    self.question_groups = []
    self.grid_answers = []
    self.current_question_group = nil
    self.current_question = nil
    self.current_dependency = nil
    self.default_options(title).merge(options).each{|key,value| self.instance_variable_set("@#{key}", value)}
  end

  def default_options(title)
    { :data_export_identifier => Surveyor.to_normalized_string(title)
    }
  end

  # This method_missing magic does all the heavy lifting for the DSL
  def method_missing(missing_method, *args, &block)    
    method_name, reference_identifier = missing_method.to_s.split("_")
    
    case method_name
      
    when "group", "g", "grid", "repeater"
      puts "    Group: #{reference_identifier}"
      raise "Error: A question group cannot be empty" unless block_given?
      
      clear_current_question
      options = {:reference_identifier => reference_identifier, :display_type => (method_name =~ /grid|repeater/)? method_name : nil }
      self.question_groups << (self.current_question_group = QuestionGroup.new(self, args, options))
      self.instance_eval(&block)
      clear_current_question_group
      
    when "question", "q", "label", "image"
      puts "      Question: #{reference_identifier}"
      raise "Error: I'm dropping the block like it's hot" if block_given?
      
      clear_current_question
      options = {:reference_identifier => reference_identifier, :question_group_id => (current_question_group ? current_question_group.id : nil)}
      options.merge!({:display_type => "label"}) if method_name == "label"
      options.merge!({:display_type => "image"}) if method_name == "image"
      self.questions << (self.current_question = Question.new(self, args, options))
      add_grid_answers if self.current_question_group and self.current_question_group.display_type == "grid"
      
    when "dependency", "d"
      puts "        Dependency: #{reference_identifier}"
      raise "Error: I'm dropping the block like it's hot" if block_given?
      raise "Error: No question or question group" unless (d = self.current_question_group || self.current_question)
      
      options = {}# {:reference_identifier => reference_identifier}
      d.dependency = (self.current_dependency = Dependency.new(d, args, options))
      
    when "condition", "c"
      puts "          Condition: #{reference_identifier}"
      raise "Error, I'm dropping the block like it's hot" if block_given?
      raise "Error: No current dependency" unless self.current_dependency
      
      options = {:rule_key => reference_identifier}
      self.current_dependency.add_dependency_condition DependencyCondition.new(self, args, options)
      
    when "answer", "a"
      puts "        Answer: #{reference_identifier}"
      raise "Error, I'm dropping the block like it's hot" if block_given?
      
      if self.current_question_group and self.current_question_group.display_type == "grid"
        options = {:reference_identifier => reference_identifier, :display_order => self.grid_answers.size + 1}
        self.grid_answers << Answer.new(nil, args, options)
      else
        raise "Error: No current question" unless self.current_question
        options = {:reference_identifier => reference_identifier, :display_order => self.current_question.answers.size + 1}
        self.current_question.answers << Answer.new(self.current_question, args, options)
      end
      
    else
      raise "  ERROR: '#{m_name}' not valid method_missing name"
    end
  end

  def clear_current_question_group
    self.current_question_group = nil
    self.grid_answers = []
    self.current_question = nil
  end

  def clear_current_question
    self.current_question = nil
    self.current_dependency = nil
  end

  def add_grid_answers
    self.grid_answers.each do |grid_answer|
      my_answer = grid_answer.dup
      my_answer.id = self.parser.new_answer_id
      my_answer.question_id = self.current_question.id
      my_answer.parser = self.parser
      self.current_question.answers << my_answer
    end
  end
  
  # Used to find questions for dependency linking 
  def find_question_by_reference(ref_id)
    self.questions.detect{|q| q.reference_identifier == ref_id}
  end
  
  def yml_attrs
    instance_variables.sort - ["@parser", "@question_groups", "@questions", "@grid_answers", "@current_question_group", "@current_question", "@current_dependency"]
  end
  def to_yml
    out = [ %(#{@data_export_identifier}_#{@id}:) ]
    yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
    (out << nil ).join("\r\n")
  end

  def to_file
    File.open(self.parser.survey_sections_yml, File::CREAT|File::APPEND|File::WRONLY) {|f| f << to_yml}
    self.question_groups.compact.map(&:to_file)
    self.questions.compact.map(&:to_file)
  end

end