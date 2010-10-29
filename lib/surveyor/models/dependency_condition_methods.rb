module Surveyor
  module Models
    module DependencyConditionMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :answer
        base.send :belongs_to, :dependency
        base.send :belongs_to, :dependent_question, :foreign_key => :question_id, :class_name => :question
        base.send :belongs_to, :question

        # Validations
        base.send :validates_presence_of, :operator, :rule_key
        base.send :validates_inclusion_of, :operator, :in => Surveyor::Common::OPERATORS
        base.send :validates_uniqueness_of, :rule_key, :scope => :dependency_id
        # this causes issues with building and saving
        # base.send :validates_numericality_of, :question_id, :answer_id, :dependency_id
        
        base.send :include, Surveyor::ActsAsResponse # includes "as" instance method

        # Class methods
        base.instance_eval do
          def operators
            Surveyor::Common::OPERATORS
          end
        end
      end

      # Instance methods
      def to_hash(response_set)
        responses = response_set.responses.select do |r| 
          question && question.answers.include?(r.answer)
        end
        {rule_key.to_sym => (!responses.empty? and self.is_met?(responses))}
      end

      # Checks to see if the responses passed in meets the dependency condition
      def is_met?(responses)
        response = if self.answer_id
                     responses.detect do |r| 
                       r.answer_id.to_i == self.answer_id.to_i
                     end 
                   end || responses.first
        klass = response.answer.response_class
        return case self.operator
        when "==", "<", ">", "<=", ">="
          response.as(klass).send(self.operator, self.as(klass))
        when "!="
          !(response.as(klass) == self.as(klass))
        else
          false
        end
      end
    end
  end
end
