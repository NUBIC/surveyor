module Surveyor
  module Models
    module QuestionGroupMethods
      def self.included(base)
        # Associations
        base.send :has_many, :questions
        base.send :has_one, :dependency
      end
      
      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.display_type ||= "inline"
      end

      def renderer
        display_type.blank? ? :default : display_type.to_sym
      end

      def display_type=(val)
        write_attribute(:display_type, val.nil? ? nil : val.to_s)
      end

      def dependent?
        self.dependency != nil
      end
      def triggered?(response_set)
        dependent? ? self.dependency.is_met?(response_set) : true
      end
      def css_class(response_set)
        [(dependent? ? "g_dependent" : nil), (triggered?(response_set) ? nil : "g_hidden"), custom_class].compact.join(" ")
      end
      def api_json(qs)
        { :text => text,
          :type => display_type,
          :answers => qs.first.answers.map(&:api_json),
          :questions => qs.map(&:api_json)}
      end
    end
  end
end