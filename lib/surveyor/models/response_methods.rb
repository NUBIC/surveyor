module Surveyor
  module Models
    module ResponseMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :response_set
        base.send :belongs_to, :question
        base.send :belongs_to, :answer

        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :question_id, :answer_id

          @@validations_already_included = true
        end
        base.send :include, Surveyor::ActsAsResponse # includes "as" instance method

        # Whitelisting attributes
        base.send :attr_accessible, :response_set, :question, :answer, :date_value, :time_value, :response_set_id, :question_id, :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other, :response_group, :survey_section_id

        # Class methods
        base.instance_eval do
          def applicable_attributes(attrs)
            result = HashWithIndifferentAccess.new(attrs)
            answer_id = result[:answer_id].is_a?(Array) ? result[:answer_id].last : result[:answer_id] # checkboxes are arrays / radio buttons are not arrays
            if result[:string_value] && !answer_id.blank? && Answer.exists?(answer_id)
              answer = Answer.find(answer_id)
              result.delete(:string_value) unless answer.response_class && answer.response_class.to_sym == :string
            end
            result
          end
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
        write_attribute :answer_id, (val.is_a?(Array) ? val.detect{|x| !x.to_s.blank?} : val)
      end
      def correct?
        question.correct_answer.nil? or self.answer.response_class != "answer" or (question.correct_answer.id.to_i == answer.id.to_i)
      end

      def time_value
        read_attribute(:datetime_value).strftime( time_format ) unless read_attribute(:datetime_value).blank?
      end

      def time_value=(val)
        self.datetime_value = Time.zone.parse("#{Date.today.to_s} #{val}") ? Time.zone.parse("#{Date.today.to_s} #{val}").to_datetime : nil
      end

      def date_value
        read_attribute(:datetime_value).strftime( date_format ) unless read_attribute(:datetime_value).blank?
      end

      def date_value=(val)
        self.datetime_value = Time.zone.parse(val) ? Time.zone.parse(val).to_datetime : nil
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
        return "" if answer.nil? || answer.response_class.nil?
        return case t = answer.response_class.to_sym
               when :string, :text, :integer, :float
                 send("#{t}_value".to_sym).to_s
               when :date
                 date_value
               when :time
                 time_value
               when :datetime
                 read_attribute(:datetime_value).strftime(datetime_format)
               else
                 to_s
               end
      end

      def to_s # used in dependency_explanation_helper
        if self.answer.response_class == "answer" and self.answer_id
          return self.answer.text
        else
          return "#{(self.string_value || self.text_value || self.integer_value || self.float_value || nil).to_s}"
        end
      end

      def json_value
        return nil if answer.response_class == "answer"

        formats = {
          'datetime' => '%Y-%m-%dT%H:%M%:z',
          'date' => '%Y-%m-%d',
          'time' => '%H:%M'
        }

        found = formats[answer.response_class]
        found ? datetime_value.try{|d| d.utc.strftime(found)} : as(answer.response_class)
      end
    end
  end
end
