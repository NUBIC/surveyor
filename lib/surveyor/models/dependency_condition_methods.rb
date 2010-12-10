module Surveyor
  module Models
    module DependencyConditionMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :answer
        base.send :belongs_to, :dependency
        base.send :belongs_to, :dependent_question, :foreign_key => :question_id, :class_name => :question
        base.send :belongs_to, :question
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :operator, :rule_key
          base.send :validate, :validates_operator
          base.send :validates_uniqueness_of, :rule_key, :scope => :dependency_id
          # this causes issues with building and saving
          # base.send :validates_numericality_of, :question_id, :dependency_id
          
          @@validations_already_included = true
        end
                
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
        # all responses to associated question
        responses = response_set.responses.select do |r| 
          question && question.answers.include?(r.answer)
        end
        {rule_key.to_sym => (!responses.empty? and self.is_met?(responses))}
      end

      # Checks to see if the responses passed in meet the dependency condition
      def is_met?(responses)
        # response to associated answer if available, or first response
        response = if self.answer_id
                     responses.detect do |r| 
                       r.answer == self.answer
                     end 
                   end || responses.first
        klass = response.answer.response_class
        return case self.operator
        when "==", "<", ">", "<=", ">="
          response.as(klass).send(self.operator, self.as(klass))
        when "!="
          !(response.as(klass) == self.as(klass))
        when /^count[<>=]{1,2}\d+$/
          op, i = self.operator.scan(/^count([<>!=]{1,2})(\d+)$/).flatten
          responses.count.send(op, i.to_i)
        when /^count!=\d+$/
          !(responses.count == self.operator.scan(/\d+/).first.to_i)
        else
          false
        end
      end

    protected

      def validates_operator
        errors.add(:operator, "Invalid operator") unless
          Surveyor::Common::OPERATORS.include?(self.operator) ||
            self.operator && self.operator.match(/^count(<|>|==|>=|<=|!=)(\d+)/)
      end
    end
  end
end
