require 'activesupport' # for pluralize

class SurveyParser
  @@models = %w(survey survey_section question_group question answer dependency dependency_condition)
  (%w(base) + @@models).each{|m| require File.dirname(__FILE__) + "/#{m}"} # require all models

  # Children, Counters, Files
  attr_accessor :surveys
  @@models.each{|m| attr_accessor "#{m.pluralize}_yml".to_sym } # for fixtures
  
  # Class methods
  def self.parse(file_name)
    puts "\n--- Parsing '#{file_name}' ---"
    parser = SurveyParser.new
    parser.instance_eval(File.read(file_name))
    parser.to_files
    puts "--- End of parsing ---\n\n"
  end

  # Instance methods
  # no more "ARRRGH, EVIL GLOBALS!!!"
  def initialize
    self.surveys = []
    self.define_counter_methods(@@models)
    self.initialize_fixtures(@@models.map(&:pluralize), File.join(RAILS_ROOT, "surveys", "fixtures"))
  end
  
  # new_survey_id, new_survey_section_id, etc.
  def define_counter_methods(names)
    names.each do |name|
      self.instance_variable_set("@last_#{name}_id", 0)
      self.class.send(:define_method, "new_#{name}_id") do # self.class.send is a hack - define_method is private
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

  def survey(title, &block)
    puts "Survey: #{title}"
    raise "ERROR: A survey cannot be empty!" unless block_given?
    new_survey = Survey.new(self.new_survey_id, self, title)
    new_survey.instance_eval(&block)    
    new_survey.reconcile_dependencies
    self.surveys << new_survey
  end

  def to_files
    self.surveys.compact.map(&:to_file)
  end

end