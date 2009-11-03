class Question < Surveyor::Base
  
  # Context, Content, Reference, Display, Children
  attr_accessor :id, :parser, :survey_section_id, :question_group_id
  attr_accessor :text, :short_text, :help_text, :pick
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier
  attr_accessor :display_order, :display_type, :is_mandatory, :display_width, :custom_class, :custom_renderer
  attr_accessor :answers, :dependency

  def initialize(section, args = [], opts = {})
    self.parser = section.parser
    self.id = parser.new_question_id
    self.survey_section_id = section.id
    self.answers = []
    super
  end
  
  def default_options
    { :pick => :none,
      :display_type => :default,
      :is_mandatory => true,
      :display_order => self.id
    }
  end
  def parse_opts(opts)
    (name = opts.delete(:method_name)) =~ /label|image/ ? opts.merge(:display_type => name) : opts
  end
  def parse_args(args)
    text = args[0] || "Question"
    {:text => text, :short_text => text, :data_export_identifier => Surveyor.to_normalized_string(text)}.merge(args[1] || {})
  end
  
  def find_answer_by_reference(ref_id)
    self.answers.detect{|a| a.reference_identifier == ref_id}
  end
  
  def yml_attrs
    super - ["@answers", "@dependency"]
  end

  def to_file
    File.open(self.parser.questions_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
    self.answers.compact.map(&:to_file)
    if self.dependency then self.dependency.to_file end
  end

end