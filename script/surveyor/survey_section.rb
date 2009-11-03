class SurveySection

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
    self.default_options(title).merge(options).each{|key,value| self.instance_variable_set("@#{key}", value)}
  end

  def default_options(title)
    { :data_export_identifier => Surveyor.to_normalized_string(title)
    }
  end

  # This method_missing magic does all the heavy lifting for the DSL
  def method_missing(missing_method, *args, &block)
    method_name, reference_identifier = missing_method.to_s.split("_", 2)
    opts = {:method_name => method_name, :reference_identifier => reference_identifier}
    case method_name
    when "group", "g", "grid", "repeater"
      self.current_question_group = QuestionGroup.new(self, args, opts)
      evaluate_the &block
      
    when "question", "q", "label", "image"
      drop_the &block
      self.current_question = Question.new(self, args, opts.merge(:question_group_id => current_question_group ? current_question_group.id : nil))
      add_grid_answers if in_a_grid?
      
    when "dependency", "d"
      drop_the &block
      self.current_dependency = Dependency.new(self.current_question_group || self.current_question, args, opts)
      
    when "condition", "c"
      drop_the &block
      raise "Error: No current dependency" if self.current_dependency.nil?
      self.current_dependency.add_dependency_condition DependencyCondition.new(self, args, opts)
      
    when "answer", "a"
      drop_the &block
      if in_a_grid?
        self.grid_answers << Answer.new(nil, args, opts.merge(:display_order => self.grid_answers.size + 1))
      else
        raise "Error: No current question" if self.current_question.nil?
        self.current_question.answers << Answer.new(self.current_question, args, opts.merge(:display_order => self.current_question.answers.size + 1))
      end
      
    else
      raise "  ERROR: '#{method_name}' not valid method"
    
    end
  end

  def drop_the(&block)
    raise "Error, I'm dropping the block like it's hot" if block_given?
  end
  
  def evaluate_the(&block)
    raise "Error: A question group cannot be empty" unless block_given?
    self.instance_eval(&block)
    clear_current_question_group
  end
  
  def current_question_group=(g)
    clear_current_question_group
    self.question_groups << g
    @current_question_group = g
  end
  
  def current_question=(q)
    clear_current_question
    self.questions << q
    @current_question = q
  end
  
  def current_dependency=(d)
    raise "Error: No question or question group" unless (dependent = self.current_question_group || self.current_question)
    dependent.dependency = d
    @current_dependency = d
  end
  
  def clear_current_question_group
    @current_question_group = nil
    self.grid_answers = []
    clear_current_question
  end

  def clear_current_question
    @current_question = nil
    @current_dependency = nil
  end
  
  def in_a_grid?
    self.current_question_group and self.current_question_group.display_type == "grid"
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