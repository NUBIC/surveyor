require 'fastercsv'
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
          else # non-header rows
            SurveySection.build_or_set(context, r)
            Question.build_and_set(context, r)
            Answer.build_and_set(context, r)
            Validation.build_and_set(context, r)
            Dependency.build_and_set(context, r)
          end        
        end
      rescue #FasterCSV::MalformedCSVError
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
  def build_or_set(context, r)
  end
  
end
class QuestionGroup < ActiveRecord::Base
  include Surveyor::Models::QuestionGroupMethods
end
class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods
  def build_and_set(context, r)
  end
  
end
class Dependency < ActiveRecord::Base
  include Surveyor::Models::DependencyMethods
  def build_and_set(context, r)
  end

end
class DependencyCondition < ActiveRecord::Base
  include Surveyor::Models::DependencyConditionMethods
end
class Answer < ActiveRecord::Base
  include Surveyor::Models::AnswerMethods
  def build_and_set(context, r)
  end

end
class Validation < ActiveRecord::Base
  include Surveyor::Models::ValidationMethods
  def build_and_set(context, r)
  end
  
end
class ValidationCondition < ActiveRecord::Base
  include Surveyor::Models::ValidationConditionMethods
end
