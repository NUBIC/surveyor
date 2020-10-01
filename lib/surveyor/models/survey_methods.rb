# frozen_string_literal: true

require 'surveyor/common'

module Surveyor
  module Models
    module SurveyMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include ActiveModel::ForbiddenAttributesProtection

      DEFAULT_SURVEY_VERSION = 1

      included do
        # Associations
        has_many :sections, -> { order(display_order: :asc) }, class_name: 'SurveySection', dependent: :destroy, autosave: true
        has_many :response_sets
        has_many :translations, class_name: 'SurveyTranslation'

        # Validations
        validates_presence_of :title
        validates_uniqueness_of :survey_version, scope: :access_code, message: 'survey with matching access code and version already exists'

        # Derived attributes
        before_validation :generate_access_code
        before_validation :increment_version
      end

      module ClassMethods
        def to_normalized_string(value)
          # replace non-alphanumeric with "-". remove repeat "-"s. don't start or end with "-"
          value.to_s.downcase.gsub(/[^a-z0-9]/, '-').gsub(/-+/, '-').gsub(/-$|^-/, '')
        end
      end

      # Instance methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def dom_class(_response_set = nil)
        ['survey',
         ("survey_#{reference_identifier}" if reference_identifier),
         custom_class].compact.join(' ')
      end

      def default_args
        self.api_id ||= Surveyor::Common.generate_api_id
        self.display_order ||= Survey.count
      end

      def active?
        active_as_of?(DateTime.now)
      end

      def active_as_of?(date)
        active_at && active_at < date && (!inactive_at || inactive_at > date) ? true : false
      end

      def activate!
        self.active_at = DateTime.now
        self.inactive_at = nil
      end

      def deactivate!
        self.inactive_at = DateTime.now
        self.active_at = nil
      end

      ##
      # A hook that allows the survey object to be modified before it is
      # serialized by the #as_json method.
      def filtered_for_json
        self
      end

      def default_access_code
        self.class.to_normalized_string(title)
      end

      def generate_access_code
        self.access_code ||= default_access_code
      end

      def increment_version
        surveys = self.class.select(:survey_version).where(access_code: access_code).order('survey_version DESC')
        self.survey_version =
          if surveys.any?
            surveys.first.survey_version.to_i + 1
          else
            DEFAULT_SURVEY_VERSION
          end
      end

      def translation(locale_symbol)
        t = translations.where(locale: locale_symbol.to_s).first
        { title: title, description: description }.with_indifferent_access.merge(
          t ? YAML.safe_load(t.translation || '{}', [Symbol]).with_indifferent_access : {},
        )
      end
    end
  end
end
