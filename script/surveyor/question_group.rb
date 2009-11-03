class QuestionGroup < Surveyor::Base

  # Context, Content, Display, Children
  attr_accessor :id, :parser
  attr_accessor :text, :help_text
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :display_type, :custom_class, :custom_renderer
  attr_accessor :dependency

  def initialize(section, args = [], opts = {})
    self.parser = section.parser
    self.id = parser.new_question_group_id  
    super
  end
  
  def default_options
    {:display_type => "default"}
  end
  def parse_args(args)
    {:text => args[0] || "Question Group"}.merge(args[1] || {})
  end
  def parse_opts(opts)
    (name = opts.delete(:method_name)) =~ /grid|repeater/ ? opts.merge(:display_type => name) : opts
  end

  def yml_attrs
    super - ["@dependency"]
  end

  def to_file
    File.open(self.parser.question_groups_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
    if self.dependency then self.dependency.to_file end
  end

end