# frozen_string_literal: true

module Surveyor
  module Models
    module SurveySectionMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        has_many :questions,
          -> { order('display_order, id ASC') },
          dependent: :destroy,
          autosave: true

        has_many :skip_logics,
          -> { order('execute_order, id ASC') },
          dependent: :destroy,
          autosave: true,
          inverse_of: :survey_section

        belongs_to :survey, optional: true

        # Validations
        validates_presence_of :title, :display_order
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.data_export_identifier ||= Surveyor::Common.normalize(title)
      end

      def dom_class(_response_set = nil)
        [reference_identifier ? "section_#{reference_identifier}" : nil,
         custom_class].compact.join(' ')
      end

      def questions_and_groups
        questions.each_with_index.map do |q, i|
          if q.part_of_group?
            if (i + 1 >= questions.size) || (q.question_group_id != questions[i + 1].question_group_id)
              q.question_group
            end
          else
            q
          end
        end.compact
      end

      def translation(locale)
        { title: title, description: description }.with_indifferent_access.merge(
          (survey.translation(locale)[:survey_sections] || {})[reference_identifier] || {},
        )
      end

      def completed?(response_set)
        questions_and_groups.each do |qg|
          if qg.is_a?(Question)
            q = qg
            if q.triggered?(response_set) && q.mandatory? && !response_set.is_answered?(q)
              return false
            end
          else
            g = qg
            if g.triggered?(response_set) &&
                g.questions.detect { |q| q.triggered?(response_set) &&
                q.mandatory? &&
                !response_set.is_answered?(q) }.nil?
              return false
            end
          end
        end

        true
      end
    end
  end
end
