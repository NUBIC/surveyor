# frozen_string_literal: true

module Surveyor
  module Models
    module DependencyMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :question, optional: true
        belongs_to :question_group, optional: true
        has_many :dependency_conditions, dependent: :destroy

        # Validations
        validates_presence_of :rule

        # TODO properly formed parenthesis etc.
        validates_format_of :rule, with: /\A(?:and|or|\)|\(|[A-Z]|\s)+\Z/

        validates_numericality_of :question_id, if: Proc.new { |d| d.question_group_id.nil? }
        validates_numericality_of :question_group_id, if: Proc.new { |d| d.question_id.nil? }

        # Attribute aliases
        alias_attribute :dependent_question_id, :question_id
      end

      # Instance Methods
      def question_group_id=(i)
        write_attribute(:question_id, nil) unless i.nil?
        write_attribute(:question_group_id, i)
      end

      def question_id=(i)
        write_attribute(:question_group_id, nil) unless i.nil?
        write_attribute(:question_id, i)
      end

      def id_for_dom
        if question_group_id.nil?
          "#{Question.param_key}_#{question_id}"
        else
          "#{QuestionGroup.param_key}_#{question_group_id}"
        end
      end

      # Has this dependency has been met in the context of response_set?
      # Substitutes the conditions hash into the rule and evaluates it
      def is_met?(response_set)
        ch = conditions_hash(response_set)
        return false if ch.blank?

        # logger.debug "rule: #{self.rule.inspect}"
        # logger.debug "rexp: #{rgx.inspect}"
        # logger.debug "keyp: #{ch.inspect}"
        # logger.debug "subd: #{self.rule.gsub(rgx){|m| ch[m.to_sym]}}"
        rgx = Regexp.new(dependency_conditions.map do |dc|
          ['a', 'o'].include?(dc.rule_key) ? "\\b#{dc.rule_key}(?!nd|r)\\b" : "\\b#{dc.rule_key}\\b"
        end.join('|')) # exclude and, or

        eval(rule.gsub(rgx) { |m| ch[m.to_sym] })
      end

      # A hash of the conditions (keyed by rule_key) and their evaluation (boolean)
      # in the context of response_set
      def conditions_hash(response_set)
        hash = {}
        dependency_conditions.each { |dc| hash.merge!(dc.to_hash(response_set)) }
        hash
      end
    end
  end
end
