require File.dirname(__FILE__) + '/columnizer'

class Question
  include Columnizer
  
  # Context, Content, Display, Reference, Children
  attr_accessor :id, :survey_section_id, :parser
  attr_accessor :text, :short_text, :help_text
  attr_accessor :pick, :display_type, :display_order, :question_group_id, :is_mandatory
  attr_accessor :reference_identifier, :data_export_identifier
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

  def to_yml
    out =[ %(#{@data_export_identifier}_#{@id}:) ]
    out << %(  id: #{@id})
    out << %(  survey_section_id: #{@survey_section_id})
    out << %(  text: "#{@text}")
    out << %(  short_text: "#{@short_text}")
    out << %(  help_text: "#{@help_text}")
    out << %(  pick: #{pick})
    out << %(  display_type: #{display_type})
    out << %(  display_order: #{display_order})
    out << %(  question_group_id: #{question_group_id})
    out << %(  is_mandatory: #{@is_mandatory})
    out << %(  reference_identifier: #{@reference_identifier})
    out << %(  data_export_identifier: "#{@data_export_identifier}")
    (out << nil ).join("\r\n")
  end
  
  def to_file
    File.open(self.parser.questions_yml, File::CREAT|File::APPEND|File::WRONLY){ |f| f << to_yml }
    self.answers.compact.map(&:to_file)
    if self.dependency then self.dependency.to_file end
  end

end