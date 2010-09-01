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
        base.send :validates_numericality_of, :dependency_id, :question_id, :answer_id
        base.send :validates_presence_of, :operator, :rule_key
        base.send :validates_inclusion_of, :operator, :in => Surveyor::Common::OPERATORS
        base.send :validates_uniqueness_of, :rule_key, :scope => :dependency_id

        base.send :acts_as_response # includes "as" instance method

        # Class methods
        base.instance_eval do
          def operators
            Surveyor::Common::OPERATORS
          end
        end
      end

      # Instance methods
      def to_hash(response_set)
        response = response_set.responses.detect{|r| r.answer_id.to_i == self.answer_id.to_i} || false # eval("nil and false") => nil so return false if no response is found
        {rule_key.to_sym => (response and self.is_met?(response))}
      end

      # Checks to see if the response passed in meets the dependency condition
      def is_met?(response)
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