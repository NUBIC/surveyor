class Dependency < Surveyor::Base
  
  # Context, Conditional, Children
  attr_accessor :id, :question_id, :question_group_id, :parser
  attr_accessor :rule
  attr_accessor :dependency_conditions

  def initialize(dependent, args = [], opts = {})
    self.parser = dependent.parser
    self.id = parser.new_dependency_id
    self.send(dependent.class == QuestionGroup ? :question_group_id= : :question_id=, dependent.id)
    self.dependency_conditions = []
    super
  end

  def parse_opts(opts)
    {} # toss the method name and reference identifier by default
  end
  # Injecting the id of the current dependency object into the dependency_condition on assignment
  def add_dependency_condition(dc_obj)
    dc_obj.dependency_id = self.id
    self.dependency_conditions << dc_obj
  end
  
  def yml_attrs
    instance_variables.sort - ["@parser", "@dependency_conditions"]
  end

  def to_file
    File.open(self.parser.dependencies_yml, File::CREAT|File::APPEND|File::WRONLY) {|f| f << to_yml}
    self.dependency_conditions.compact.map(&:to_file)  
  end

end