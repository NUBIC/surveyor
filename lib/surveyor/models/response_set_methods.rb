# frozen_string_literal: true

module Surveyor
  module Models
    module ResponseSetMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :survey, optional: false
        belongs_to :user, optional: true
        belongs_to :current_section,
          foreign_key: :current_section_id,
          class_name: :survey_section,
          optional: true
        has_many :responses, dependent: :destroy
        accepts_nested_attributes_for :responses, allow_destroy: true

        if defined? ActiveModel::MassAssignmentSecurity
          attr_accessible *PermittedParams.new.response_set_attributes
        end

        # Validations
        validates_presence_of :survey_id
        validates_associated :responses
        validates_uniqueness_of :access_code

        # Derived attributes
        before_create :ensure_start_timestamp
        before_create :ensure_identifiers
      end

      module ClassMethods
        def has_blank_value?(hash)
          return true if hash['answer_id'].blank?
          return false if (q = Question.find_by_id(hash['question_id'])) && (q.pick == 'one')

          hash.any? { |_k, v| v.is_a?(Array) ? v.all? { |x| x.to_s.blank? } : v.to_s.blank? }
        end
      end

      def ensure_start_timestamp
        self.started_at ||= Time.now
      end

      def ensure_identifiers
        self.access_code ||= Surveyor::Common.make_tiny_code
        self.api_id ||= Surveyor::Common.generate_api_id
      end

      def to_csv(access_code = false, print_header = true)
        result = Surveyor::Common.csv_impl.generate do |csv|
          if print_header
            csv << (access_code ? ['response set access code'] : []) +
              csv_question_columns.map { |qcol| "question.#{qcol}" } +
              csv_answer_columns.map { |acol| "answer.#{acol}" } +
              csv_response_columns.map { |rcol| "response.#{rcol}" }
          end
          responses.each do |response|
            csv << (access_code ? [self.access_code] : []) +
              csv_question_columns.map { |qcol| response.question.send(qcol) } +
              csv_answer_columns.map { |acol| response.answer.send(acol) } +
              csv_response_columns.map { |rcol| response.send(rcol) }
          end
        end
        result
      end

      %w(question answer response).each do |model|
        define_method "csv_#{model}_columns" do
          model.capitalize.constantize.content_columns.map(&:name) - (
            model == 'response' ? [] : %w(created_at updated_at)
          )
        end
      end

      def complete!
        self.completed_at = Time.now
      end

      def complete?
        !completed_at.nil?
      end

      def correct?
        responses.all?(&:correct?)
      end

      def correctness_hash
        {
          questions:
            Survey
              .where(id: survey_id)
              .includes(sections: :questions)
              .first
              .sections
              .map(&:questions)
              .flatten
              .compact
              .size,
          responses: responses.compact.size,
          correct: responses.select(&:correct?).compact.size,
        }
      end

      def mandatory_questions_complete?
        progress_hash[:triggered_mandatory] == progress_hash[:triggered_mandatory_completed]
      end

      def progress_hash
        qs =
          Survey
            .where(id: survey_id)
            .includes(sections: :questions)
            .first
            .sections
            .map(&:questions)
            .flatten

        ds = dependencies(qs.map(&:id))
        triggered = qs - ds.reject { |d| d.is_met?(self) }.map(&:question)

        {
          questions: qs.compact.size,
          triggered: triggered.compact.size,
          triggered_mandatory: triggered.select(&:mandatory?).compact.size,
          triggered_mandatory_completed:
            triggered.select { |q| q.mandatory? and is_answered?(q) }.compact.size,
        }
      end

      def is_answered?(question)
        %w(label image).include?(question.display_type) or !is_unanswered?(question)
      end

      def is_unanswered?(question)
        responses.detect { |r| r.question_id == question.id && !r.to_formatted_s.blank? }.nil?
      end

      def is_group_unanswered?(group)
        group.questions.any? { |question| is_unanswered?(question) }
      end

      # Returns the number of response groups (count of group responses entered) for this group
      def count_group_responses(questions)
        questions.map do |q|
          responses.select do |r|
            (r.question_id.to_i == q.id.to_i) && !r.response_group.nil?
          end.group_by(&:response_group).size
        end.max
      end

      def unanswered_dependencies
        unanswered_question_dependencies + unanswered_question_group_dependencies
      end

      def unanswered_question_dependencies
        dependencies.select do |d|
          d.question && is_unanswered?(d.question) && d.is_met?(self)
        end.map(&:question)
      end

      def unanswered_question_group_dependencies
        dependencies.select do |d|
          d.question_group && is_group_unanswered?(d.question_group) && d.is_met?(self)
        end.map(&:question_group)
      end

      def all_dependencies(question_ids = nil)
        arr = dependencies(question_ids).partition { |d| d.is_met?(self) }
        {
          show: arr[0].map(&:id_for_dom),
          hide: arr[1].map(&:id_for_dom),
        }
      end

      # Check existence of responses to questions from a given survey_section
      def no_responses_for_section?(section)
        responses.none? { |r| r.survey_section_id == section.id }
      end

      def update_from_ui_hash(ui_hash)
        transaction do
          ui_hash.each do |ord, response_hash|
            api_id = response_hash['api_id']
            fail "api_id missing from response #{ord}" unless api_id

            existing = Response.where(api_id: api_id).first
            updateable_attributes = response_hash.reject { |k, _v| k == 'api_id' }

            if self.class.has_blank_value?(response_hash)
              existing&.destroy
            elsif existing
              if existing.question_id.to_s != updateable_attributes['question_id']
                fail "Illegal attempt to change question for response #{api_id}."
              end

              existing.update_attributes(updateable_attributes)
            else
              responses.build(updateable_attributes).tap do |r|
                r.api_id = api_id
                r.save!
              end
            end
          end
        end
      end

      def is_qualified?
        survey.sections.map(&:questions).flatten.each do |question|
          if is_answered?(question) && question.triggered?(self) && !question.qualified?(self)
            return false
          end
        end

        true
      end

      protected

      def dependencies(question_ids = nil)
        if responses.blank? && question_ids.blank?
          question_ids = survey.sections.map(&:questions).flatten.map(&:id)
        end

        deps =
          Dependency
            .includes(:dependency_conditions)
            .where({
              dependency_conditions: {
                question_id: question_ids || responses.map(&:question_id)
              },
            })

        # this is a work around for a bug in active_record in rails 2.3 which incorrectly
        # eager-loads associations when a condition clause includes an association limiter
        deps.each { |d| d.dependency_conditions.reload }
        deps
      end
    end
  end
end
