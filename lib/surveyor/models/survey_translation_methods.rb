module Surveyor
  module Models
    module SurveyTranslationMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :survey

        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :locale, :translation
          base.send :validates_uniqueness_of, :locale, :scope => :survey_id
          # this causes issues with building and saving
          #, :survey

          @@validations_already_included = true
        end

        # Whitelisting attributes
        base.send :attr_accessible, :survey, :survey_id, :locale, :translation
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
      end
    end
  end
end