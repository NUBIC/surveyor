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

        # Validations
        base.send :validates_presence_of, :text, :survey_section_id, :display_order
        base.send :validates_inclusion_of, :is_mandatory, :in => [true, false]
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

      def renderer(g = question_group)
        r = [g ? g.renderer.to_s : nil, display_type].compact.join("_")
        r.blank? ? :default : r.to_sym
      end
    end
  end
end