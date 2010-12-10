module Surveyor
  module Models
    module SurveyMethods
      def self.included(base)
        # Associations
        base.send :has_many, :sections, :class_name => "SurveySection", :order => 'display_order'
        base.send :has_many, :sections_with_questions, :include => :questions, :class_name => "SurveySection", :order => 'display_order'
        base.send :has_many, :response_sets

        # Scopes
        base.send :named_scope, :with_sections, {:include => :sections}
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :title
          base.send :validates_uniqueness_of, :access_code
          
          @@validations_already_included = true
        end        

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
        self.inactive_at ||= DateTime.now
      end

      def title=(value)
        adjusted_value = value
        while Survey.find_by_access_code(Survey.to_normalized_string(adjusted_value))
          i ||= 0
          i += 1
          adjusted_value = "#{value} #{i.to_s}"
        end
        self.access_code = Survey.to_normalized_string(adjusted_value)
        super(adjusted_value)        
        # self.access_code = Survey.to_normalized_string(value)
        # super
      end

      def active?
        self.active_as_of?(DateTime.now)
      end
      def active_as_of?(datetime)
        (self.active_at.nil? or self.active_at < datetime) and (self.inactive_at.nil? or self.inactive_at > datetime)
      end  
      def activate!
        self.active_at = DateTime.now
      end
      def deactivate!
        self.inactive_at = DateTime.now
      end
      def active_at=(datetime)
        self.inactive_at = nil if !datetime.nil? and !self.inactive_at.nil? and self.inactive_at < datetime
        super(datetime)
      end
      def inactive_at=(datetime)
        self.active_at = nil if !datetime.nil? and !self.active_at.nil? and self.active_at > datetime
        super(datetime)
      end
    end
  end
end