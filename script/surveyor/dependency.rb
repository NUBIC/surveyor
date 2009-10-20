class Dependency
  
  # Context, Conditional, Children
  attr_accessor :id, :question_id, :question_group_id, :parser
  attr_accessor :rule
  attr_accessor :dependency_conditions

  # id, question, and rule required
  def initialize(question, args, options)
    self.parser = question.parser
    self.id = parser.new_dependency_id
    if question.class == QuestionGroup
      self.question_group_id = question.id
    else
      self.question_id = question.id
    end
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
  
  def yml_attrs
    instance_variables.sort - ["@parser", "@dependency_conditions", "@reference_identifier"]
  end
  def to_yml
    out = [ %(#{@data_export_identifier}_#{@id}:) ]
    yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
    (out << nil ).join("\r\n")
  end

  def to_file
    File.open(self.parser.dependencies_yml, File::CREAT|File::APPEND|File::WRONLY) {|f| f << to_yml}
    self.dependency_conditions.compact.map(&:to_file)  
  end
  
  

end