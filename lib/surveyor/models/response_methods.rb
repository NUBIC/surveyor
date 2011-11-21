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
          base.send :validates, :float_value, :numericality => true, :if => "validate?(%w[float])"
          base.send :validates, :integer_value, :numericality => { :only_integer => true }, :if => "validate?(%w[integer])"
          
          @@validations_already_included = true
        end
        base.send :include, Surveyor::ActsAsResponse # includes "as" instance method
        
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
      def answer_id=(val)
        write_attribute :answer_id, (val.is_a?(Array) ? val.detect{|x| !x.to_s.blank?} : val)
      end
      def correct?
        question.correct_answer.nil? or self.answer.response_class != "answer" or (question.correct_answer.id.to_i == answer.id.to_i)
      end
      
      def validate?(fields)
        return false if self.answer.nil?
        return true if !marked_for_destruction? && fields.include?(self.answer.response_class)
        return false
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
