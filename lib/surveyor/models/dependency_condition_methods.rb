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

        # Whitelisting attributes
        base.send :attr_accessible, :dependency, :question, :answer, :dependency_id, :rule_key, :question_id, :operator, :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other

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
        responses = question.blank? ? [] : response_set.responses.where("responses.answer_id in (?)", question.answer_ids).all
        if self.operator.match /^count(>|>=|<|<=|==|!=)\d+$/
          op, i = self.operator.scan(/^count(>|>=|<|<=|==|!=)(\d+)$/).flatten
          # logger.warn({rule_key.to_sym => responses.count.send(op, i.to_i)})
          return {rule_key.to_sym => (op == "!=" ? !responses.count.send("==", i.to_i) : responses.count.send(op, i.to_i))}
        elsif operator == "!=" and (responses.blank? or responses.none?{|r| r.answer.id == self.answer.id})
          # logger.warn( {rule_key.to_sym => true})
          return {rule_key.to_sym => true}
        elsif response = responses.detect{|r| r.answer.id == self.answer.id}
          klass = response.answer.response_class
          klass = "answer" if self.as(klass).nil? # it should compare answer ids when the dependency condition *_value is nil
          case self.operator
          when "==", "<", ">", "<=", ">="
            # logger.warn( {rule_key.to_sym => response.as(klass).send(self.operator, self.as(klass))})
            return {rule_key.to_sym => !response.as(klass).nil? && response.as(klass).send(self.operator, self.as(klass))}
          when "!="
            # logger.warn( {rule_key.to_sym => !response.as(klass).send("==", self.as(klass))})
            return {rule_key.to_sym => !response.as(klass).send("==", self.as(klass))}
          end
        end
        # logger.warn({rule_key.to_sym => false})
        {rule_key.to_sym => false}
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
