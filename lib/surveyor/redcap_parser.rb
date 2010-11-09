require 'fastercsv'
require 'active_support' # for humanize
module Surveyor
  class RedcapParser
    # Attributes
    attr_accessor :context

    # Class methods
    def self.parse(str, filename)
      puts
      Surveyor::RedcapParser.new.parse(str, filename)
      puts
      puts
    end
    
    # Instance methods
    def initialize
      self.context = {}
    end
    def parse(str, filename)
      begin
        FasterCSV.parse(str, :headers => :first_row, :return_headers => true, :header_converters => :symbol) do |r|
          if r.header_row? # header row
            return puts "Missing headers: #{missing_columns(r).inspect}\n\n" unless missing_columns(r).blank?
            context[:survey] = Survey.new(:title => filename)
            print "survey_#{context[:survey].access_code} "
          else # non-header rows
            SurveySection.build_or_set(context, r)
            Question.build_and_set(context, r)
            Answer.build_and_set(context, r)
            # Validation.build_and_set(context, r)
            # Dependency.build_and_set(context, r)
          end
        end
      rescue FasterCSV::MalformedCSVError
        puts = "Oops. Not a valid CSV file."
      # ensure
      end
    end
    def missing_columns(r)
      required_columns - r.headers.map(&:to_s)
    end
    def required_columns
      %w(variable__field_name form_name field_units section_header field_type field_label choices_or_calculations field_note text_validation_type text_validation_min text_validation_max identifier branching_logic_show_field_only_if required_field)
    end
  end
end

# Surveyor models with extra parsing methods
class Survey < ActiveRecord::Base
  include Surveyor::Models::SurveyMethods
end
class SurveySection < ActiveRecord::Base
  include Surveyor::Models::SurveySectionMethods
  def self.build_or_set(context, r)
    unless context[:survey_section] && context[:survey_section].reference_identifier == r[:form_name]
      if match = context[:survey].sections.detect{|ss| ss.reference_identifier == r[:form_name]}
        context[:current_survey_section] = match
      else
        context[:survey_section] = context[:survey].sections.build({:title => r[:form_name].to_s.humanize, :reference_identifier => r[:form_name]})
        print "survey_section_#{context[:survey_section].reference_identifier} "
      end
    end
  end
end
class QuestionGroup < ActiveRecord::Base
  include Surveyor::Models::QuestionGroupMethods
end
class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods
  def self.build_and_set(context, r)
    if !r[:section_header].blank?
      context[:survey_section].questions.build({:display_type => "label", :text => r[:section_header]})
      print "label_ "
    end
    context[:question] = context[:survey_section].questions.build({
      :reference_identifier => r[:variable__field_name],
      :text => r[:field_label],
      :help_text => r[:field_note],
      :is_mandatory => (/^y/i.match r[:required_field]) ? true : false,
      :pick => pick_from_field_type(r[:field_type]),
      :display_type => display_type_from_field_type(r[:field_type])
    })
    print "question_#{context[:question].reference_identifier} "
  end
  def self.pick_from_field_type(ft)
    {"checkbox" => :any, "radio" => :one}[ft] || :none
  end
  def self.display_type_from_field_type(ft)
    {"text" => :string, "dropdown" => :dropdown, "notes" => :text}[ft]
  end
end
class Dependency < ActiveRecord::Base
  include Surveyor::Models::DependencyMethods
  def self.build_and_set(context, r)
  end
end
class DependencyCondition < ActiveRecord::Base
  include Surveyor::Models::DependencyConditionMethods
end
class Answer < ActiveRecord::Base
  include Surveyor::Models::AnswerMethods
  def self.build_and_set(context, r)
    r[:choices_or_calculations].to_s.split("|").each do |pair|
      aref, atext = pair.strip.split(", ")
      context[:answer] = context[:question].answers.build({
        :reference_identifier => aref,
        :text => atext
      })
      print "answer_#{context[:answer].reference_identifier} "
    end
  end
end
class Validation < ActiveRecord::Base
  include Surveyor::Models::ValidationMethods
  def self.build_and_set(context, r)
  end
  
end
class ValidationCondition < ActiveRecord::Base
  include Surveyor::Models::ValidationConditionMethods
end
