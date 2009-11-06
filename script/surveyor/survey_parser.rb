require 'activesupport' # for pluralize, humanize in ActiveSupport::CoreExtensions::String::Inflections

class SurveyParser
  @@models = %w(survey survey_section question_group question answer dependency dependency_condition)
  
  # Require all models
  (%w(base) + @@models).each{|m| require File.dirname(__FILE__) + "/#{m}"}

  # Children, fixtures
  attr_accessor :surveys
  @@models.each{|m| attr_accessor "#{m.pluralize}_yml".to_sym } # for fixtures
  attr_accessor :current_survey, :current_survey_section, :current_question_group, :current_question, :current_dependency, :grid_answers
  
  # Class methods
  def self.parse(file_name)
    self.define_counter_methods(@@models)
    puts "\n--- Parsing '#{file_name}' ---"
    parser = SurveyParser.new
    parser.instance_eval(File.read(file_name))
    parser.to_files
    puts "--- End of parsing ---\n\n"
  end

  # new_survey_id, new_survey_section_id, etc.
  def self.define_counter_methods(names)
    names.each do |name|
      define_method("new_#{name}_id") do
        instance_variable_set("@last_#{name}_id", instance_variable_get("@last_#{name}_id") + 1)
      end
    end
  end
  
  # Instance methods
  def initialize
    self.surveys = []
    self.grid_answers = []
    initialize_counters(@@models)
    initialize_fixtures(@@models.map(&:pluralize), File.join(RAILS_ROOT, "surveys", "fixtures"))
  end
  
  # last_survey_id, last_survey_section_id, etc.
  def initialize_counters(names)
    names.each{|name| instance_variable_set("@last_#{name}_id", 0)}
  end

  # surveys_yml, survey_sections_yml, etc.
  def initialize_fixtures(names, path)
    names.each {|name| file = self.instance_variable_set("@#{name}_yml", "#{path}/#{name}.yml"); File.truncate(file, 0) if File.exist?(file) }
  end

  # This method_missing magic does all the heavy lifting for the DSL
  def method_missing(missing_method, *args, &block)
    method_name, reference_identifier = missing_method.to_s.split("_", 2)
    opts = {:method_name => method_name, :reference_identifier => reference_identifier}
    case method_name
    when "survey"
      self.current_survey = Survey.new(self, args, opts)
      evaluate_the "survey", &block
    
    when "section"
      self.current_survey_section = SurveySection.new(self.current_survey, args, opts.merge({:display_order => current_survey.survey_sections.size + 1}))
      evaluate_the "survey_section", &block
      
    when "group", "g", "grid", "repeater"
      self.current_question_group = QuestionGroup.new(self.current_survey_section, args, opts)
      evaluate_the "question_group", &block
      
    when "question", "q", "label", "image"
      drop_the &block
      self.current_question = Question.new(self.current_survey_section, args, opts.merge(:question_group_id => current_question_group ? current_question_group.id : nil))
      add_grid_answers if in_a_grid?
      
    when "dependency", "d"
      drop_the &block
      self.current_dependency = Dependency.new(self.current_question_group || current_question, args, opts)
      
    when "condition", "c"
      drop_the &block
      raise "Error: No current dependency" if self.current_dependency.nil?
      self.current_dependency.dependency_conditions << DependencyCondition.new(current_dependency, args, opts)
      
    when "answer", "a"
      drop_the &block
      if in_a_grid?
        self.grid_answers << Answer.new(nil, args, opts.merge(:display_order => grid_answers.size + 1))
      else
        raise "Error: No current question" if self.current_question.nil?
        self.current_question.answers << Answer.new(self.current_question, args, opts.merge(:display_order => current_question.answers.size + 1))
      end
      
    else
      raise "  ERROR: '#{method_name}' not valid method"
    
    end
  end

  def drop_the(&block)
    raise "Error, I'm dropping the block like it's hot" if block_given?
  end
  
  def evaluate_the(model, &block)
    raise "Error: A #{model.humanize} cannot be empty" unless block_given?
    self.instance_eval(&block)
    self.send("clear_current", model)
  end
  
  def clear_current(model)
    puts "clear_current #{model}"
    case model
    when "survey"
      current_survey.reconcile_dependencies unless current_survey.nil?
    when "question_group"
      grid_answers = []
      clear_current("question")
    when "question"
      @current_dependency = nil
    end
    instance_variable_set("@current_#{model}", nil)
    model.classify.constantize.send(:children).each{|m| clear_current(m.to_s)}
  end
  
  def current_survey=(s)
    clear_current_survey
    self.surveys << s
    @current_survey = s
  end
  def clear_current_survey
    current_survey.reconcile_dependencies unless current_survey.nil?
    # @current_survey = nil
    # clear_current_survey_section
  end
  
  def current_survey_section=(s)
    clear_current_survey_section
    self.current_survey.survey_sections << s
    @current_survey_section = s 
  end
  def clear_current_survey_section
    # @current_survey_section = nil
    # clear_current_question_group
  end
  
  def current_question_group=(g)
    clear_current_question_group
    self.current_survey_section.question_groups << g
    @current_question_group = g
  end
  def clear_current_question_group
    @current_question_group = nil
    self.grid_answers = []
    # clear_current_question
  end
  
  def current_question=(q)
    clear_current_question
    self.current_survey_section.questions << q
    @current_question = q
  end
  def clear_current_question
    @current_question = nil
    @current_dependency = nil
  end
  
  def current_dependency=(d)
    raise "Error: No question or question group" unless (dependent = self.current_question_group || self.current_question)
    dependent.dependency = d
    @current_dependency = d
  end
  
  def in_a_grid?
    self.current_question_group and self.current_question_group.display_type == "grid"
  end
  
  def add_grid_answers
    self.grid_answers.each do |grid_answer|
      my_answer = grid_answer.dup
      my_answer.id = self.new_answer_id
      my_answer.question_id = self.current_question.id
      my_answer.parser = self
      self.current_question.answers << my_answer
    end
  end

  def to_files
    self.surveys.compact.map(&:to_file)
  end

end