require 'uuid'

module Surveyor
  module Models
    module AnswerMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :question
        base.send :has_many, :responses
        base.send :has_many, :validations, :dependent => :destroy
        
        # Scopes
        base.send :default_scope, :order => "display_order ASC"
        base.scope :by_question_answer_data_export_identifier, lambda { |survey_id, question_data_export_identifier, answer_data_export_identifier| 
							base.joins(:question, :question => :survey_section).where(
							:questions => {:data_export_identifier => question_data_export_identifier}, 
							:answers => {:data_export_identifier => answer_data_export_identifier},
							:survey_sections => {:survey_id => survey_id}
					)}
  
        base.scope :by_question_data_export_identifier, lambda { |survey_id, question_data_export_identifier, answer_text| 
							base.joins(:question, :question => :survey_section).where(
							:questions => {:data_export_identifier => question_data_export_identifier}, 
							:answers => {:text =>  answer_text},
							:survey_sections => {:survey_id => survey_id}
					)}
  
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :text
          # this causes issues with building and saving
          # base.send :validates_numericality_of, :question_id, :allow_nil => false, :only_integer => true
          @@validations_already_included = true
        end
        
        # Class methods
        base.instance_eval do
          def find_by_survey_question_answer(survey_id, question_data_export_identifier, answer_data_export_identifier)
            Answer.by_question_answer_data_export_identifier(survey_id, question_data_export_identifier, answer_data_export_identifier).first
          end
                
          def find_by_survey_question_answer_text(survey_id, question_data_export_identifier, answer_text)
            Answer.by_question_data_export_identifier(survey_id, question_data_export_identifier, answer_text).first
          end
        end
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.is_exclusive ||= false
        self.display_type ||= "default"
        self.response_class ||= "answer"
        self.short_text ||= text
        self.data_export_identifier ||= Surveyor::Common.normalize(text)
        self.api_id ||= UUID.generate
      end
      
      def css_class
        [(is_exclusive ? "exclusive" : nil), custom_class].compact.join(" ")
      end
      
      def split_or_hidden_text(part = nil)
        return "" if display_type == "hidden_label"
        part == :pre ? text.split("|",2)[0] : (part == :post ? text.split("|",2)[1] : text)
      end
    end
  end
end
