require File.dirname(__FILE__) + '/columnizer'

class Question
  include Columnizer
  
  # Context, Content, Reference, Display, Children
  attr_accessor :id, :parser, :survey_section_id, :question_group_id
  attr_accessor :text, :short_text, :help_text, :pick
  attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :display_order, :display_type, :is_mandatory, :display_width, :custom_class, :custom_renderer
  attr_accessor :answers, :dependency

  def initialize(section, args, options)
    self.parser = section.parser
    self.id = parser.new_question_id
    self.display_order = self.id
    self.survey_section_id = section.id
    self.text = args[0]
    self.answers = []
    self.dependency = nil
    self.default_options(text).merge(options).merge(args[1] || {}).each{|key,value| self.instance_variable_set("@#{key}", value)}
  end
  
  def default_options(text)
    { :short_text => text,
      :pick => :none,
      :display_type => :default,
      :is_mandatory => true,
      :data_export_identifier => Columnizer.to_normalized_column(text)
    }
  end
  
  # Injecting the id of this question object into the dependency object on assignment
  def dependency=(dep)
    unless dep.nil?
      dep.question_id = self.id
    end
    @dependency = dep
  end
  
  def find_answer_by_reference(ref_id)
    answer = nil
    count = 0
    puts "Looking up answer with ref: #{ref_id}"
    while answer.nil? and count < self.answers.size
      answer = self.answers[count] if self.answers[count].reference_identifier == ref_id
      count += 1
    end
    puts "  found answer: '#{answer.text}' (id:#{answer.id})"  unless answer.nil?
    answer
  end
  
  def yml_attrs
    instance_variables.sort - ["@parser", "@answers", "@dependency"]
  end
  def to_yml
    out = [ %(#{@data_export_identifier}_#{@id}:) ]
    yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
    (out << nil ).join("\r\n")
  end
  
  def to_file
    File.open(self.parser.questions_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
    self.answers.compact.map(&:to_file)
    if self.dependency then self.dependency.to_file end
  end

end