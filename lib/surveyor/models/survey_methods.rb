require 'surveyor/common'
require 'rabl'

module Surveyor
  module Models
    module SurveyMethods
      def self.included(base)
        # Associations
        base.send :has_many, :sections, :class_name => "SurveySection", :order => 'display_order', :dependent => :destroy
        base.send :has_many, :sections_with_questions, :include => :questions, :class_name => "SurveySection", :order => 'display_order'
        base.send :has_many, :response_sets

        # Scopes
        base.send :scope, :with_sections, {:include => :sections}
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :title
          base.send :validates_uniqueness_of, :survey_version, :scope => :access_code, :message => "survey with matching access code and version already exists"
          
          @@validations_already_included = true
        end
        
        # Whitelisting attributes
        base.send :attr_accessible, :title, :description, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :css_url, :custom_class, :display_order

        # Class methods
        base.instance_eval do
          def to_normalized_string(value)
            # replace non-alphanumeric with "-". remove repeat "-"s. don't start or end with "-"
            value.to_s.downcase.gsub(/[^a-z0-9]/,"-").gsub(/-+/,"-").gsub(/-$|^-/,"")
          end
        end
      end

      # Instance methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.api_id ||= Surveyor::Common.generate_api_id
        self.display_order ||= Survey.count
      end

      def title=(value)
        return if value == self.title
        surveys = Survey.where(:access_code => Survey.to_normalized_string(value)).order("survey_version DESC")
        self.survey_version     = surveys.first.survey_version.to_i + 1 if surveys.any?
        self.access_code = Survey.to_normalized_string(value)
        super(value)
        # self.access_code = Survey.to_normalized_string(value)
        # super
      end

      def active?
        self.active_as_of?(DateTime.now)
      end
      def active_as_of?(date)
        (active_at && active_at < date && (!inactive_at || inactive_at > date)) ? true : false
      end
      def activate!
        self.active_at = DateTime.now
        self.inactive_at = nil
      end
      def deactivate!
        self.inactive_at = DateTime.now
        self.active_at = nil
      end
      def as_json(options = nil)
        template_path = ActionController::Base.view_paths.find("export", ["surveyor"], false, {:handlers=>[:rabl], :locale=>[:en], :formats=>[:json]}, [], []).inspect
        engine = Rabl::Engine.new(File.read(template_path))
        engine.to_hash((options || {}).merge(:object => self))
      end
      
    end
  end
end
