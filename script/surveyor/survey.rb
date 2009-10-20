require File.dirname(__FILE__) + '/survey_section'

class Survey
  include Columnizer
  # Context, Content, Reference, Expiry, Display, Children
  attr_accessor :id, :parser
  attr_accessor :title, :description
  attr_accessor :access_code, :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
  attr_accessor :active_at, :inactive_at
  attr_accessor :css_url, :custom_class
  attr_accessor :survey_sections
  
  @@current_survey = nil
  
  def self.current_survey
    @@current_survey
  end
  
  def self.current_survey=(value)
    @@current_survey = value
    puts "Assigning current survey #{@@current_survey.title}"
  end
  
  # id, parser, and title required
  def initialize(id, parser, title, options = {})
    self.id = id
    self.parser = parser
    self.title = title
    self.survey_sections = []
    self.access_code = Columnizer.to_normalized_column(title)
    # self.default_options(title).merge(options).each{|key,value| self.instance_variable_set("@#{key}", value)}
    Survey.current_survey = self
  end
  
  # def default_options(title)
  #   {}
  # end

  # This method_missing magic does all the heavy lifting for the DSL
  def method_missing(missing_method, *args, &block)
    m_name = missing_method.to_s
    if (section_match = m_name.match(/(\Asection)_?(.*)/))
      build_survey_section(section_match[3].to_s, *args, &block) # Parse "section" method, create new section in this survey
    else
      puts "  ERROR: '#{m_name}' not valid method_missing name"
    end
  end
  
  def build_survey_section(reference_identifier, title, &block)
    puts "  Section: #{title}"
    if block_given?
      new_survey_section = SurveySection.new(new_survey_section_id, self, title, {:display_order => self.survey_sections.size + 1, :reference_identifier => reference_identifier})
      new_survey_section.instance_eval(&block)
      add_survey_section(new_survey_section)
      puts "  Section added"
    else
      puts "  ERROR: A section cannot be empty!"
    end
  end
  
  def new_survey_section_id
    self.parser.new_survey_section_id
  end
  
  def add_survey_section(survey_section)
    self.survey_sections << survey_section
  end
 
  # Used to find questions for dependency linking
  def find_question_by_reference(ref_id)
    question = nil
    count = 0
    while question.nil? and count < self.survey_sections.size
      question = self.survey_sections[count].find_question_by_reference(ref_id)
      count += 1
    end
    question
  end
  
  
  def reconcile_dependencies
    @survey_sections.each do |section|
      section.questions.each do |question| 
        question.dependency.dependency_conditions.each { |con| con.reconcile_dependencies} unless question.dependency.nil?
      end
    end  
  end

  def yml_attrs
    instance_variables.sort - ["@parser", "@survey_sections"]
  end
  def to_yml
    out = [ %(survey_#{@id}:) ]
    yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
    (out << nil ).join("\r\n")
  end

  def to_file
    "survey -#{self.title}- written to file..."
    File.open(self.parser.surveys_yml, File::CREAT|File::APPEND|File::WRONLY) {|f| f << to_yml}
    self.survey_sections.compact.map(&:to_file)
  end
 
end