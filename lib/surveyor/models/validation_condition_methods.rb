module Surveyor
  module Models
    module ValidationConditionMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :validation

        # Scopes
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :operator, :rule_key
          base.send :validates_inclusion_of, :operator, :in => Surveyor::Common::OPERATORS
          base.send :validates_uniqueness_of, :rule_key, :scope => :validation_id
          # this causes issues with building and saving
          # base.send :validates_numericality_of, :validation_id #, :question_id, :answer_id
          
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

      # Instance Methods
      def to_hash(response)
        {rule_key.to_sym => (response.nil? ? false : self.is_valid?(response))}
      end

      def is_valid?(response)
        klass = response.answer.response_class
        compare_to = Response.find_by_question_id_and_answer_id(self.question_id, self.answer_id) || self
        case self.operator
        when "==", "<", ">", "<=", ">="
          response.as(klass).send(self.operator, compare_to.as(klass))
        when "!="
          !(response.as(klass) == compare_to.as(klass))
        when "=~"
          return false if compare_to != self
          !(response.as(klass).to_s =~ Regexp.new(self.regexp || "")).nil?
        else
          false
        end
      end
    end
  end
end