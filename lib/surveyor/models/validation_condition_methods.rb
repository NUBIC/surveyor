# frozen_string_literal: true

module Surveyor
  module Models
    module ValidationConditionMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include Surveyor::ActsAsResponse # includes "as" instance method
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :validation, optional: true

        # Validations
        validates_presence_of :operator, :rule_key
        validates_inclusion_of :operator, in: Surveyor::Common::OPERATORS
        validates_uniqueness_of :rule_key, scope: :validation_id
      end

      # Instance Methods
      def to_hash(response)
        { rule_key.to_sym => (response.nil? ? false : is_valid?(response)) }
      end

      def is_valid?(response)
        klass = response.answer.response_class
        compare_to = Response.find_by_question_id_and_answer_id(question_id, answer_id) || self
        case operator
        when '==', '<', '>', '<=', '>='
          response.as(klass).send(operator, compare_to.as(klass))
        when '!='
          response.as(klass) != compare_to.as(klass)
        when '=~'
          return false if compare_to != self

          !(response.as(klass).to_s =~ Regexp.new(regexp || '')).nil?
        else
          false
        end
      end
    end
  end
end
