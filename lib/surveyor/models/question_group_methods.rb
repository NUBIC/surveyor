# frozen_string_literal: true

require 'surveyor/common'

module Surveyor
  module Models
    module QuestionGroupMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include MustacheContext
      include ActiveModel::ForbiddenAttributesProtection
      include CustomModelNaming

      included do
        # Associations
        has_many :questions
        has_one :dependency

        self.param_key = :g
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.display_type ||= 'inline'
        self.api_id ||= Surveyor::Common.generate_api_id
      end

      def renderer
        display_type.blank? ? :default : display_type.to_sym
      end

      def display_type=(val)
        write_attribute(:display_type, val.nil? ? nil : val.to_s)
      end

      def dependent?
        dependency != nil
      end

      def triggered?(response_set)
        dependent? ? dependency.is_met?(response_set) : true
      end

      def dom_class(response_set = nil)
        ["g_#{renderer}",
         (dependent? ? 'g_dependent' : nil),
         (triggered?(response_set) ? nil : 'g_hidden'),
         custom_class].compact.join(' ')
      end

      def css_class(_response_set)
        dom_class
      end

      def text_for(context = nil, locale = nil)
        return '' if display_type == 'hidden_label'

        in_context(translation(locale)[:text], context)
      end

      def help_text_for(context = nil, locale = nil)
        in_context(translation(locale)[:help_text], context)
      end

      def translation(locale)
        { text: text, help_text: help_text }.with_indifferent_access.merge(
          (questions.first.survey_section.survey.translation(locale)[:question_groups] || {})[reference_identifier] || {},
        )
      end
    end
  end
end
