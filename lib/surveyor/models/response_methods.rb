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
          base.send :validates_presence_of, :response_set_id, :question_id, :answer_id
          
          @@validations_already_included = true
        end
        
        base.send :include, Surveyor::ActsAsResponse # includes "as" instance method

      end

      # Instance Methods
      def selected
        !self.new_record?
      end

      alias_method :selected?, :selected

      def selected=(value)
        true
      end

      def correct?
        question.correct_answer_id.nil? or self.answer.response_class != "answer" or (question.correct_answer_id.to_i == answer_id.to_i)
      end

      def to_s # used in dependency_explanation_helper
        if self.answer.response_class == "answer" and self.answer_id
          return self.answer.text
        else
          return "#{(self.string_value || self.text_value || self.integer_value || self.float_value || nil).to_s}"
        end
      end
    end
  end
end