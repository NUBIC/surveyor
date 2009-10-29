class Answer  
  # Context, Content, Reference, Display
  attr_accessor :id, :parser, :question_id
  attr_accessor :text, :short_text, :help_text, :weight, :response_class
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :display_order, :is_exclusive, :hide_label, :display_length, :custom_class, :custom_renderer
  
  def initialize(question, args, options)
    self.parser = question ? question.parser : nil
    self.id = parser ? parser.new_answer_id : nil
    self.question_id = question ? question.id : nil

    #self.text is set in args
    args_options = parse_args_options(args)
    self.default_options(args_options[:text]).merge(options).merge(args_options).each{|key,value| self.instance_variable_set("@#{key}", value)}
  end
  
  def default_options(text)
    { :short_text => text,
      :data_export_identifier => Surveyor.to_normalized_string(text),
      :is_exclusive => false,
      :hide_label => false,
      :response_class => "answer"
    }
  end
  
  def parse_args_options(args)
    a0, a1, a2 = args
    
    # Hash
    if a0.is_a?(Hash)
      {:text => "Answer"}.merge(a0)
      
    # (String, Hash) or (String, Symbol, Hash)
    elsif a0.is_a?(String)
      a1.is_a?(Symbol) ? {:text => a0, :response_class => a1.to_s}.merge(a2 || {}) : {:text => a0}.merge(a1 || {})
      
    # (Symbol, Hash) or (Symbol, Symbol, Hash)
    elsif a0.is_a?(Symbol)
      shortcuts = case a0
      when :other
        {:text => "Other"}
      when :other_and_string
        {:text => "Other", :response_class => "string"}
      when :none, :omit #a disabler erases and disables all other answer options (text, checkbox, dropdowns, etc). Unchecking the omit box is the only way to enable other options (except in the case limit => :one)
        {:text => a0.to_s.humanize, :is_exclusive => true} # "omit" is no longer a response class... it's treated as any other answer type 
      when :integer, :date, :time, :datetime, :text, :datetime, :string
        {:text => a0.to_s.humanize, :response_class => a0.to_s, :hide_label => true}
      else
        {:text => a0.to_s.humanize}
      end
      a1.is_a?(Symbol) ? shortcuts.merge({:response_class => a1.to_s}).merge(a2 || {}) : shortcuts.merge(a1 || {})
    else
      {:text => "Answer"}
    end
  end

  def yml_attrs
    instance_variables.sort - ["@parser"]
  end
  def to_yml
    out = [ %(#{@data_export_identifier}_#{@id}:) ]
    yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
    (out << nil ).join("\r\n")
  end

  def to_file
     File.open(self.parser.answers_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
  end
  
end