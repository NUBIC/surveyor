class QuestionGroup

  # Context, Content, Display, Children
  attr_accessor :id, :parser
  attr_accessor :text, :help_text
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :display_type, :custom_class, :custom_renderer
  attr_accessor :dependency

  # id, section and text required
  def initialize(section, args, options)
    self.parser = section.parser
    self.id = parser.new_question_group_id
    self.text = args[0]
    self.default_options().merge(options).merge(args[1] || {}).each{|key,value| self.instance_variable_set("@#{key}", value)}
  end
  
  def default_options()
    {:display_type => "default"}
  end

  def yml_attrs
    instance_variables.sort - ["@parser", "@dependency"]
  end
  def to_yml
    out = [ %(#{@id}:) ]
    yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
    (out << nil ).join("\r\n")
  end

  def to_file
    File.open(self.parser.question_groups_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
  end

end