require 'uuid'

module Surveyor
  module Models
    module QuestionMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :survey_section
        base.send :belongs_to, :question_group, :dependent => :destroy
        base.send :has_many, :answers, :order => "display_order ASC", :dependent => :destroy # it might not always have answers
        base.send :has_one, :dependency, :dependent => :destroy
        base.send :has_one, :correct_answer, :class_name => "Answer", :dependent => :destroy

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
        self.api_id ||= UUID.generate
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
        [(dependent? ? "q_dependent" : nil), (triggered?(response_set) ? nil : "q_hidden"), custom_class].compact.join(" ")
      end

      def part_of_group?
        !self.question_group.nil?
      end
      def solo?
        self.question_group.nil?
      end
      
      def split_text(part = nil)
        (part == :pre ? text.split("|",2)[0] : (part == :post ? text.split("|",2)[1] : text)).to_s
      end
      
      def renderer(g = question_group)
        r = [g ? g.renderer.to_s : nil, display_type].compact.join("_")
        r.blank? ? :default : r.to_sym
      end
      
      def api_json
        {:text => split_text(:pre), :uuid => api_id}\
          .merge(split_text(:post).blank? ? {} : {:post_text => split_text(:post)})\
          .merge((answers.empty? or (part_of_group? and question_group.display_type == "grid")) ? {} : {:answers => answers.map(&:api_json)})\
          .merge(display_type == "default" ? {} : {:type => display_type})\
          .merge(reference_identifier.blank? ? {} : {:reference => reference_identifier})\
          .merge(pick == "none" ? {} : {:pick => pick})
      end
    end
  end
end