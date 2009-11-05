class QuestionGroup < SurveyParser::Base
  # Context, Content, Display, Children
  attr_accessor :id, :parser
  attr_accessor :text, :help_text
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :display_type, :custom_class, :custom_renderer
  attr_accessor :dependency

  def default_options
    {:display_type => "default"}
  end
  def parse_args(args)
    {:text => args[0] || "Question Group"}.merge(args[1] || {})
  end
  def parse_opts(opts)
    (name = opts.delete(:method_name)) =~ /grid|repeater/ ? opts.merge(:display_type => name) : opts
  end

  def to_file
    super
    if self.dependency then self.dependency.to_file end
  end

end