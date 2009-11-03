class Answer < Surveyor::Base
  # Context, Content, Reference, Display
  attr_accessor :id, :parser, :question_id
  attr_accessor :text, :short_text, :help_text, :weight, :response_class
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :display_order, :is_exclusive, :hide_label, :display_length, :custom_class, :custom_renderer
  
  def initialize(question, args, options)
    self.parser = question ? question.parser : nil
    self.id = parser ? parser.new_answer_id : nil
    self.question_id = question ? question.id : nil
    super
  end
  
  def default_options
    { :is_exclusive => false,
      :hide_label => false,
      :response_class => "answer"
    }
  end
  
  def parse_args(args)
    a, b, c = args
    case a
    when Hash # Hash
      text_args(a[:text]).merge(a)
    when String # (String, Hash) or (String, Symbol, Hash)
      text_args(a).merge(hash_from b).merge(c || {})
    when Symbol # (Symbol, Hash) or (Symbol, Symbol, Hash)
      symbol_args(a).merge(hash_from b).merge(c || {})
    else
      text_args(nil)
    end
  end
  
  def text_args(text = "Answer")
    {:text => text.to_s, :short_text => text, :data_export_identifier => Surveyor.to_normalized_string(text)}
  end
  def hash_from(arg)
    arg.is_a?(Symbol) ? {:response_class => arg.to_s} : arg.is_a?(Hash) ? arg : {}
  end
  def symbol_args(arg)
    case arg
    when :other
      text_args("Other")
    when :other_and_string
      text_args("Other").merge({:response_class => "string"})
    when :none, :omit # is_exclusive erases and disables other checkboxes and input elements
      text_args(arg.to_s.humanize).merge({:is_exclusive => true})
    when :integer, :date, :time, :datetime, :text, :datetime, :string
      text_args(arg.to_s.humanize).merge({:response_class => arg.to_s, :hide_label => true})
    end
  end
  
  def to_file
     File.open(self.parser.answers_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
  end
  
end