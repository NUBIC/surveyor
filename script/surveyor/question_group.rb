class QuestionGroup
  
  # Context, Content, Display
  attr_accessor :id, :section_id, :section, :parser
  attr_accessor :text, :help_text
  attr_accessor :display_type

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
  
  def to_yml
    out =[ %(#{@id}:) ]
    out << %(  id: #{@id})
    out << %(  text: "#{@text}")
    out << %(  help_text: "#{@help_text}")
    out << %(  display_type: "#{@display_type}")
    (out << nil ).join("\r\n")
  end

  def to_file
    File.open(self.parser.question_groups_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
  end

end