require 'activesupport' # for pluralize, humanize in ActiveSupport::CoreExtensions::String::Inflections
module SurveyParser
  class Parser
    @@models = %w(survey survey_section question_group question answer dependency dependency_condition validation validation_condition)
    # Require base and all models
    (%w(base) + @@models).each{|m| require File.dirname(__FILE__) + "/#{m}"}

    # Attributes
    attr_accessor :salt, :surveys, :grid_answers, :counters
    @@models.each{|m| attr_accessor "#{m.pluralize}_yml".to_sym } # for fixtures
    (@@models - %w(dependency_condition validation_condition)).each {|m| attr_accessor "current_#{m}".to_sym} # for current_model caches
  
    # Class methods
    def self.parse(file_name)
      puts "\n--- Parsing '#{file_name}' ---"
      parser = SurveyParser::Parser.new
      parser.instance_eval(File.read(file_name))
      parser.to_files
      puts "--- End of parsing ---\n\n"
    end

    def next_id(sym)
      counters[sym] ||= 0
      counters[sym] += 1
    end
    
    # Instance methods
    def initialize
      self.salt = Time.now.strftime("%Y%m%d%H%M%S")
      self.surveys = []
      self.grid_answers = []
      initialize_fixtures(@@models.map(&:pluralize), File.join(RAILS_ROOT, "surveys", "fixtures"))
      self.counters = {}
    end

    # @surveys_yml, @survey_sections_yml, etc.
    def initialize_fixtures(names, path)
      names.each {|name| file = instance_variable_set("@#{name}_yml", "#{path}/#{name}.yml"); File.truncate(file, 0) if File.exist?(file) }
    end

    # This method_missing does all the heavy lifting for the DSL
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
        raise "Error: No current dependency or validation for this condition" if self.current_dependency.nil? && self.current_validation.nil?
        if self.current_dependency.nil?
          self.current_validation.validation_conditions << ValidationCondition.new(self.current_validation, args, opts)
        else
          self.current_dependency.dependency_conditions << DependencyCondition.new(self.current_dependency, args, opts)
        end
      
      when "answer", "a"
        drop_the &block
        if in_a_grid?
          self.grid_answers << Answer.new(nil, args, opts.merge(:display_order => grid_answers.size + 1))
        else
          raise "Error: No current question" if self.current_question.nil?
          self.current_answer = Answer.new(self.current_question, args, opts.merge(:display_order => current_question.answers.size + 1))
        end
        
      when "correct"
        drop_the &block
        raise "Error: No current question" if self.current_question.nil?
        self.current_correct_answer = self.current_question.find_current_answers(args)
    
      when "validation", "v"
        drop_the &block
        self.current_validation = Validation.new(self.current_answer, args, opts)


      # explicitly define a dependency condition
      # (not really necessary as is default)
      when "dependencycondition", "dcondition", "dc"
        drop_the &block
        raise "Error: No current dependency for this condition" if self.current_dependency.nil?
        self.current_dependency.dependency_conditions << DependencyCondition.new(self.current_dependency, args, opts)

      # explicitly define a validation condition
      # (is necessary if want dependency AND validation on
      #  same question as dependency existance would try to
      #  make the condition a dependency condition.)
      when "validationcondition", "vcondition", "vc"
        drop_the &block
        raise "Error: No current validation for this condition" if self.current_validation.nil?
        self.current_validation.validation_conditions << ValidationCondition.new(self.current_validation, args, opts)
      


      else
        raise "  ERROR: '#{missing_method}' not valid method"
    
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
      # puts "clear_current #{model}"
      case model
      when "survey"
        self.current_survey.reconcile_dependencies unless current_survey.nil?
      when "question_group"
        self.grid_answers = []
        clear_current("question")
      when "question"
        @current_dependency = nil
      when "answer"
        @current_validation = nil
      end
      instance_variable_set("@current_#{model}", nil)
      "SurveyParser::#{model.classify}".constantize.send(:children).each{|m| clear_current(m.to_s.singularize)}
    end
  
    def current_survey=(s)
      clear_current "survey"
      self.surveys << s
      @current_survey = s
    end
    
    def current_survey_section=(s)
      clear_current "survey_section"
      self.current_survey.survey_sections << s
      @current_survey_section = s 
    end
    
    def current_question_group=(g)
      clear_current "question_group"
      self.current_survey_section.question_groups << g
      @current_question_group = g
    end
    
    def current_question=(q)
      clear_current "question"
      self.current_survey_section.questions << q
      @current_question = q
    end
    
    def current_dependency=(d)
      raise "Error: No question or question group" unless (dependent = self.current_question_group || self.current_question)
      dependent.dependency = d
      @current_dependency = d
    end
    
    def current_answer=(a)
      raise "Error: No current question" if self.current_question.nil?
      self.current_question.answers << a
      @current_answer = a
    end
    
    def current_correct_answer=(a)
      raise "Error: No current question" if self.current_question.nil?
      self.current_question.correct_answer = a
    end
    
    def current_validation=(v)
      clear_current "validation"
      self.current_answer.validation = v
      @current_validation = v
    end

    def in_a_grid?
      self.current_question_group and self.current_question_group.display_type == "grid"
    end
  
    def add_grid_answers
      self.grid_answers.each do |grid_answer|
        my_answer = grid_answer.dup
        my_answer.id = next_id(:answer)
        my_answer.question_id = self.current_question.id
        my_answer.parser = self
        self.current_answer = my_answer
      end
    end

    def to_files
      self.surveys.compact.map(&:to_file)
    end

  end
end
