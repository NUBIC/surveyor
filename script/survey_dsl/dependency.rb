class Dependency
  
  # Context, Conditional, Children
  attr_accessor :id, :question_id, :parser
  attr_accessor :rule
  attr_accessor :dependency_conditions

  # id, question, and rule required
  def initialize(question, args, options)
    self.parser = question.parser
    self.id = parser.new_dependency_id
    self.question_id = question.id
    self.rule = (args[0] || {})[:rule]
    self.dependency_conditions = []
    self.default_options().merge(options).merge(args[1] || {}).each{|key,value| self.instance_variable_set("@#{key}", value)}
  end
  
  def default_options()
    {}
  end
  
  # Injecting the id of the current dependency object into the dependency_condition on assignment
  def add_dependency_condition(dc_obj)
    dc_obj.dependency_id = self.id
    self.dependency_conditions << dc_obj
  end
  
  def to_yml
    out =[ %(#{question_id}_#{@id}:) ]
    out << %(  id: #{@id})
    out << %(  question_id: #{@question_id})
    out << %(  rule: "#{@rule}")
    (out << nil ).join("\r\n")
  end

  def to_file
    File.open(self.parser.dependencies_yml, File::CREAT|File::APPEND|File::WRONLY) {|f| f << to_yml}
    self.dependency_conditions.compact.map(&:to_file)  
  end
  
  

end