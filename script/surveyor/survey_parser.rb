require File.dirname(__FILE__) + '/survey'

class SurveyParser
  # Children, Counters, Files
  attr_accessor :surveys
  attr_accessor :last_survey_id, :last_survey_section_id, :last_question_id, :last_answer_id
  attr_accessor :surveys_yml, :survey_sections_yml, :question_groups_yml, :questions_yml, :answers_yml, :dependencies_yml, :dependency_conditions_yml

  # no more "ARRRGH, EVIL GLOBALS!!!"
  def initialize
    self.surveys = []
    self.define_counter_methods(%w(survey survey_section question_group question answer dependency dependency_condition))
    self.initialize_fixtures(%w(surveys survey_sections question_groups questions answers dependencies dependency_conditions), File.join(RAILS_ROOT, "surveys", "fixtures"))
  end

  # new_survey_id, new_survey_section_id, etc.
  def define_counter_methods(names)
    names.each do |name|
      self.instance_variable_set("@last_#{name}_id", 0)
      # self.class.send is a hack - define_method is private
      self.class.send(:define_method, "new_#{name}_id") do
        self.instance_variable_set("@last_#{name}_id", self.instance_variable_get("@last_#{name}_id") + 1)
      end
    end
  end

  # surveys_yml, survey_sections_yml, etc.
  def initialize_fixtures(names, path)
    names.each do |name|
      file = self.instance_variable_set("@#{name}_yml", "#{path}/#{name}.yml")
      File.truncate(file, 0) if File.exist?(file)
    end
  end

  def self.parse(file_name)
    puts "--- Parsing '#{file_name}' ---"
    parser = SurveyParser.new
    parser.instance_eval(File.read(file_name), file_name)
    parser.to_files
    puts "--- End of parsing ---"
  end

  def survey(title, &block)
    puts "Survey: #{title}"
    if block_given?
      new_survey = Survey.new(self.new_survey_id, self, title)
      new_survey.instance_eval(&block)    
      new_survey.reconcile_dependencies
      add_survey(new_survey)
      puts "Survey added"
    else
      puts "ERROR: A survey cannot be empty!"
    end
  end

  def add_survey(survey)
    self.surveys << survey
  end

  def to_files
    self.surveys.compact.map(&:to_file)
  end

end