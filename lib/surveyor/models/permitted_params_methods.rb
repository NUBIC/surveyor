module Surveyor
  module Models
    module PermittedParamsMethods
      extend ActiveSupport::Concern

      included do
        # Class Methods
      end

      # Instance Methods
      def strong_parameters
        ActionController::Parameters.new(params)
      end
      # survey
      def survey
        strong_parameters.permit(*survey_attributes)
      end
      def survey_attributes
        [:title, :description, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :css_url, :custom_class, :display_order]
      end

      # survey_translation
      def survey_translation
        strong_parameters.permit(*survey_translation_attributes)
      end
      def survey_translation_attributes
        [:survey, :survey_id, :locale, :translation]
      end

      # survey_section
      def survey_section
        strong_parameters.permit(*survey_section_attributes)
      end
      def survey_section_attributes
        [:survey, :survey_id, :title, :description, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :custom_class, :display_order]
      end

      # question
      def question
        strong_parameters.permit(*question_attributes)
      end
      def question_attributes
        [:survey_section, :question_group, :survey_section_id, :question_group_id, :text, :short_text, :help_text, :pick, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :display_order, :display_type, :is_mandatory, :display_width, :custom_class, :custom_renderer, :correct_answer_id]
      end

      # question_group
      def question_group
        strong_parameters.permit(*question_group_attributes)
      end
      def question_group_attributes
        [:text, :help_text, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :display_type, :custom_class, :custom_renderer]
      end

      # answer
      def answer
        strong_parameters.permit(*answer_attributes)
      end
      def answer_attributes
        [:question, :question_id, :text, :short_text, :help_text, :weight, :response_class, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :display_order, :is_exclusive, :display_length, :custom_class, :custom_renderer, :default_value, :display_type, :input_mask, :input_mask_placeholder]
      end

      # dependency
      def dependency
        strong_parameters.permit(*dependency_attributes)
      end
      def dependency_attributes
        [:question, :question_group, :question_id, :question_group_id, :rule]
      end

      # dependency_condition
      def dependency_condition
        strong_parameters.permit(*dependency_condition_attributes)
      end
      def dependency_condition_attributes
        [:dependency, :question, :answer, :dependency_id, :rule_key, :question_id, :operator, :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other, :question_reference, :answer_reference]
      end

      # validation
      def validation
        strong_parameters.permit(*validation_attributes)
      end
      def validation_attributes
        [:answer, :answer_id, :rule, :message]
      end

      # validation_condition
      def validation_condition
        strong_parameters.permit(*validation_condition_attributes)
      end
      def validation_condition_attributes
        [:validation, :validation_id, :rule_key, :operator, :question_id, :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other, :regexp]
      end

      # response
      def response
        strong_parameters.permit(*response_attributes)
      end
      def response_attributes
        [:response_set, :question, :answer, :date_value, :time_value, :response_set_id, :question_id, :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other, :response_group, :survey_section_id]
      end

      # response_set
      def response_set
        strong_parameters.permit(*response_set_attributes)
      end
      def response_set_attributes
        [:survey, :responses_attributes, :user_id, :survey_id]
      end

      # skip_logic
      def skip_logic
        strong_parameters.permit(*skip_logic_attributes)
      end
      def skip_logic_attributes
        [:survey_section, :target_survey_section, :survey_section_id, :target_survey_section_id, :rule, :execute_order, :target_survey_section_reference]
      end

      #skip logic conditions
      def skip_logic_condition
        strong_parameters.permit(*skip_logic_condition_attributes)
      end
      def skip_logic_condition_attributes
        [:skip_logic, :question, :answer, :skip_logic_id, :rule_key, :question_id, :operator, :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other, :question_reference, :answer_reference]
      end
    end
  end
end