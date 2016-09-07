module Surveyor
  module Models
    module SurveySectionMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        has_many :questions, -> { order( 'display_order, id ASC' ) }, :dependent => :destroy, :autosave => true
        belongs_to :survey
        attr_accessible *PermittedParams.new.survey_section_attributes if defined? ActiveModel::MassAssignmentSecurity

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

      def dom_class(response_set = nil)
        [ self.reference_identifier ? "section_#{self.reference_identifier}" : nil,
          self.custom_class ].compact.join(" ")
      end

      def questions_and_groups
        qs = []
        questions.each_with_index.map do |q,i|
          if q.part_of_group?
            if (i+1 >= questions.size) or (q.question_group_id != questions[i+1].question_group_id)
              q.question_group
            end
          else
            q
          end
        end.compact
      end

      def translation(locale)
        {:title => self.title, :description => self.description}.with_indifferent_access.merge(
          (self.survey.translation(locale)[:survey_sections] || {})[self.reference_identifier] || {}
        )
      end

      def completed?( response_set )
        self.questions_and_groups.each do |qg|
          if qg.is_a?( Question )
            q = qg
            return false if q.triggered?( response_set ) && q.mandatory? && !q.answered?( response_set )
          else
            g = qg
            return false if g.triggered?( response_set ) && g.questions.detect{ |q| q.triggered?( response_set ) && q.mandatory? && !q.answered?( response_set ) }.nil?
          end
        end

        return true
      end
    end
  end
end
