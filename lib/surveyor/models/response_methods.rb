# frozen_string_literal: true

module Surveyor
  module Models
    module ResponseMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include Surveyor::ActsAsResponse # includes "as" instance method
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :response_set, optional: true
        belongs_to :question, optional: true
        belongs_to :answer, optional: true

        # Validations
        validates_presence_of :question_id, :answer_id
      end

      module ClassMethods
        def applicable_attributes(attrs)
          result = HashWithIndifferentAccess.new(attrs)

          # checkboxes are arrays / radio buttons are not arrays
          answer_id = result[:answer_id].is_a?(Array) ? result[:answer_id].last : result[:answer_id]

          if result[:string_value] && !answer_id.blank? && Answer.exists?(answer_id)
            answer = Answer.find(answer_id)

            unless answer.response_class && answer.response_class.to_sym == :string
              result.delete(:string_value)
            end
          end
          result
        end
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.api_id ||= Surveyor::Common.generate_api_id
      end

      def answer_id=(val)
        write_attribute :answer_id, (val.is_a?(Array) ? val.detect { |x| !x.to_s.blank? } : val)
      end

      def correct?
        question.correct_answer.nil? ||
          answer.response_class != 'answer' ||
          (question.correct_answer.id.to_i == answer.id.to_i)
      end

      def time_value
        unless read_attribute(:datetime_value).blank?
          read_attribute(:datetime_value).strftime(time_format)
        end
      end

      def time_value=(val)
        self.datetime_value =
          if val && time = Time.zone.parse("#{Date.today} #{val}")
            time.to_datetime
          end
      end

      def date_value
        unless read_attribute(:datetime_value).blank?
          read_attribute(:datetime_value).strftime(date_format)
        end
      end

      def date_value=(val)
        self.datetime_value =
          if val && time = Time.zone.parse(val)
            time.to_datetime
          end
      end

      def time_format
        '%H:%M'
      end

      def date_format
        '%Y-%m-%d'
      end

      def datetime_format
        '%Y-%m-%d %H:%M:%S'
      end

      def to_formatted_s
        return '' if answer.nil? || answer.response_class.nil?

        case t = answer.response_class.to_sym
        when :string, :text, :integer, :float
          send("#{t}_value".to_sym).to_s
        when :date
          date_value
        when :time
          time_value
        when :datetime
          unless read_attribute(:datetime_value).blank?
            read_attribute(:datetime_value).strftime(datetime_format)
          else
            ''
          end
        else
          to_s
        end
      end

      def to_s # used in dependency_explanation_helper
        if (answer.response_class == 'answer') && answer_id
          answer.text
        else
          ((string_value || text_value || integer_value || float_value || nil)).to_s
        end
      end

      def json_value
        return nil if answer.response_class == 'answer'

        formats = {
          'datetime' => '%Y-%m-%dT%H:%M%:z',
          'date' => '%Y-%m-%d',
          'time' => '%H:%M',
        }

        found = formats[answer.response_class]
        found ? datetime_value.try { |d| d.utc.strftime(found) } : as(answer.response_class)
      end
    end
  end
end
