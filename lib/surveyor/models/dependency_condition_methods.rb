module Surveyor
  module Models
    module DependencyConditionMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include Surveyor::ActsAsResponse # includes "as" instance method
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :answer
        belongs_to :dependency
        belongs_to :dependent_question, :foreign_key => :question_id, :class_name => :question
        belongs_to :question
        attr_accessible *PermittedParams.new.dependency_condition_attributes if defined? ActiveModel::MassAssignmentSecurity

        # Validations
        validates_presence_of :operator, :rule_key
        validate :validates_operator
        validates_uniqueness_of :rule_key, :scope => :dependency_id
      end

      module ClassMethods
        def operators
          Surveyor::Common::OPERATORS
        end
      end

      # Instance methods
      def to_hash(response_set)
        # all responses to associated question
        responses = question.blank? ? [] : response_set.responses.where("responses.answer_id in (?)", question.answer_ids)
        if self.operator.match /^count(>|>=|<|<=|==|!=)\d+$/
          op, i = self.operator.scan(/^count(>|>=|<|<=|==|!=)(\d+)$/).flatten
          # logger.warn({rule_key.to_sym => responses.count.send(op, i.to_i)})
          return {rule_key.to_sym => (op == "!=" ? !responses.count.send("==", i.to_i) : responses.count.send(op, i.to_i))}
        elsif operator == "!=" and (responses.blank? or responses.none?{|r| r.answer.id == self.answer.id})
          # logger.warn( {rule_key.to_sym => true})
          return {rule_key.to_sym => true}
        elsif response = responses.to_a.detect{|r| r.answer.id == self.answer.id}
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
