# frozen_string_literal: true

require 'surveyor/common'

module Surveyor
  module Models
    module SkipLogicMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :survey_section, inverse_of: :skip_logics, optional: true
        belongs_to :target_survey_section,
          foreign_key: :target_survey_section_id,
          class_name: 'SurveySection',
          optional: true
        has_many :skip_logic_conditions, inverse_of: :skip_logic, dependent: :destroy

        # Validations
        validates_presence_of :rule
        # TODO properly formed parenthesis etc.
        validates_format_of :rule, with: /\A(?:and|or|\)|\(|[A-Z]|\s)+\Z/
        validates_presence_of :survey_section
      end

      # Has this skip_logic has been met in the context of response_set?
      # Substitutes the conditions hash into the rule and evaluates it
      def is_met?(response_set)
        ch = conditions_hash(response_set)
        return false if ch.blank?

        # logger.debug "rule: #{self.rule.inspect}"
        # logger.debug "rexp: #{rgx.inspect}"
        # logger.debug "keyp: #{ch.inspect}"
        # logger.debug "subd: #{self.rule.gsub(rgx){|m| ch[m.to_sym]}}"

        rgx_values = skip_logic_conditions.map do |slc|
          if ['a', 'o'].include?(slc.rule_key)
            "\\b#{slc.rule_key}(?!nd|r)\\b"
          else
            "\\b#{slc.rule_key}\\b"
          end
        end.join('|')

        rgx = Regexp.new(rgx_values) # exclude and, or
        eval(rule.gsub(rgx) { |m| ch[m.to_sym] })
      end

      # A hash of the conditions (keyed by rule_key) and their evaluation (boolean)
      # in the context of response_set
      def conditions_hash(response_set)
        hash = {}
        skip_logic_conditions.each { |slc| hash.merge!(slc.to_hash(response_set)) }
        hash
      end
    end
  end
end
