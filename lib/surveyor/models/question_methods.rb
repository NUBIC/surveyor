module Surveyor
  module Models
    module QuestionMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :survey_section
        base.send :belongs_to, :question_group, :dependent => :destroy
        base.send :has_many, :answers, :order => "display_order ASC", :dependent => :destroy # it might not always have answers
        base.send :has_one, :dependency, :dependent => :destroy

        # Scopes
        base.send :default_scope, :order => "display_order ASC"
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :text, :display_order
          # this causes issues with building and saving
          #, :survey_section_id
          base.send :validates_inclusion_of, :is_mandatory, :in => [true, false]
          
          @@validations_already_included = true
        end
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.is_mandatory ||= true
        self.display_type ||= "default"
        self.pick ||= "none"
        self.display_order ||= self.survey_section ? self.survey_section.questions.count : 0
        self.data_export_identifier ||= Surveyor::Common.normalize(text)
        self.short_text ||= text
      end
      
      def pick=(val)
        write_attribute(:pick, val.nil? ? nil : val.to_s)
      end
      def display_type=(val)
        write_attribute(:display_type, val.nil? ? nil : val.to_s)
      end

      def mandatory?
        self.is_mandatory == true
      end

      def dependent?
        self.dependency != nil
      end
      def triggered?(response_set)
        dependent? ? self.dependency.is_met?(response_set) : true
      end
      def css_class(response_set)
        [(dependent? ? "dependent" : nil), (triggered?(response_set) ? nil : "hidden"), custom_class].compact.join(" ")
      end

      def part_of_group?
        !self.question_group.nil?
      end
      def solo?
        self.question_group.nil?
      end

      def renderer(g = question_group)
        r = [g ? g.renderer.to_s : nil, display_type].compact.join("_")
        r.blank? ? :default : r.to_sym
      end
    end
  end
end