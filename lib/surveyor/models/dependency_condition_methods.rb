# frozen_string_literal: true

module Surveyor
  module Models
    module DependencyConditionMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include Surveyor::ActsAsResponse # includes "as" instance method
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :answer, optional: true
        belongs_to :dependency, optional: true

        # what is the difference between :dependency_question and :question?
        belongs_to :dependent_question,
          foreign_key: :question_id,
          class_name: :question,
          optional: true
        belongs_to :question, optional: true

        if defined? ActiveModel::MassAssignmentSecurity
          attr_accessible *PermittedParams.new.dependency_condition_attributes
        end

        # Validations
        validates_presence_of :operator, :rule_key
        validate :validates_operator
        validates_uniqueness_of :rule_key, scope: :dependency_id
      end

      module ClassMethods
        def operators
          Surveyor::Common::OPERATORS
        end
      end

      # Instance methods
      def to_hash(response_set)
        # all responses to associated question
        responses =
          if question.blank?
            []
          else
            response_set.responses.where('responses.answer_id in (?)', question.answer_ids)
          end

        if operator.match /^count(>|>=|<|<=|==|!=)\d+$/
          op, i = operator.scan(/^count(>|>=|<|<=|==|!=)(\d+)$/).flatten
          # logger.warn({rule_key.to_sym => responses.count.send(op, i.to_i)})

          rule_key_value =
            if op == '!='
              !responses.count.send('==', i.to_i)
            else
              responses.count.send(op, i.to_i)
            end

          return { rule_key.to_sym => rule_key_value }
        elsif (operator == '!=') &&
            (responses.blank? || responses.none? { |r| r.answer.id == answer.id })
          # logger.warn( {rule_key.to_sym => true})
          return { rule_key.to_sym => true }
        elsif response = responses.to_a.detect { |r| r.answer.id == answer.id }
          klass = response.answer.response_class
          if as(klass).nil?
            # it should compare answer ids when the dependency condition *_value is nil
            klass = 'answer'
          end

          case operator
          when '==', '<', '>', '<=', '>='
            # logger.warn( {rule_key.to_sym => response.as(klass).send(self.operator, self.as(klass))})
            return { rule_key.to_sym => !response.as(klass).nil? && response.as(klass).send(operator, as(klass)) }
          when '!='
            # logger.warn( {rule_key.to_sym => !response.as(klass).send("==", self.as(klass))})
            return { rule_key.to_sym => !response.as(klass).send('==', as(klass)) }
          end
        end
        # logger.warn({rule_key.to_sym => false})
        { rule_key.to_sym => false }
      end

      protected

      def validates_operator
        unless Surveyor::Common::OPERATORS.include?(operator) ||
            operator&.match(/^count(<|>|==|>=|<=|!=)(\d+)/)
          errors.add(:operator, 'Invalid operator')
        end
      end
    end
  end
end
