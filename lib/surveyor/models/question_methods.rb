require 'surveyor/common'

module Surveyor
  module Models
    module QuestionMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include MustacheContext
      include ActiveModel::ForbiddenAttributesProtection
      include CustomModelNaming

      included do
        # Associations
        belongs_to :survey_section, required: false
        belongs_to :question_group, dependent: :destroy, required: false
        has_many :answers, -> { order( 'display_order, id ASC' ) }, dependent: :destroy, autosave: true # it might not always have answers
        has_one :dependency, :dependent => :destroy
        belongs_to :correct_answer, class_name: "Answer", dependent: :destroy, required: false
        attr_accessible *PermittedParams.new.question_attributes if defined? ActiveModel::MassAssignmentSecurity
        attr_accessor :response_group
        # Validations
        validates_presence_of :text, :display_order
        validates_inclusion_of :is_mandatory, :in => [true, false]
        validates_inclusion_of :pick, :in => ["one", "any", "none"]

        self.param_key = :q
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end
      def to_key
        [id, response_group].compact
      end
      def default_args
        self.is_mandatory ||= false
        self.display_type ||= "default"
        self.pick ||= "none"
        self.data_export_identifier ||= Surveyor::Common.normalize(text)
        self.short_text ||= text
        self.api_id ||= Surveyor::Common.generate_api_id
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
      def qualified?(response_set)
        responses = response_set.responses.select{ |r| r.question_id == self.id }
        case self.pick
        when "one"
          if responses.empty?
            return !self.mandatory?
          else
            return self.answers.find{ |a| a.id == responses.first.answer_id }.qualify_logic != "reject"
          end
        when "any"
          if responses.empty? && !self.mandatory?
            return true
          else
            num_must = self.answers.select{ |a| a.qualify_logic == "must" }.size
            chosen_answers = responses.map{ |r| self.answers.find{ |a| a.id == r.answer_id } }

            return chosen_answers.find{ |a| a.qualify_logic == "reject" }.nil? &&
              chosen_answers.select{ |a| a.qualify_logic == "must" }.size == num_must
          end
        when "none"
          return true
        end
      end
      def dom_class(response_set = nil)
        [ (dependent? ? "q_dependent" : nil),
          (triggered?(response_set) ? nil : "q_hidden"),
          custom_class,
          "q_#{renderer(question_group)}"
        ].compact.join(" ")
      end
      def css_class(response_set)
        dom_class(response_set)
      end
      def part_of_group?
        !self.question_group.nil?
      end
      def solo?
        self.question_group.nil?
      end

      def text_for(position = nil, context = nil, locale = nil)
        return "" if display_type == "hidden_label"
        imaged(split(in_context(translation(locale)[:text], context), position))
      end
      def help_text_for(context = nil, locale = nil)
        in_context(translation(locale)[:help_text], context)
      end
      def split(text, position=nil)
        case position
        when :pre
          text.split("|",2)[0]
        when :post
          text.split("|",2)[1]
        else
          text
        end.to_s
      end
      def renderer(g = nil)
        r = [g.try(:renderer), display_type].compact.join("_")
        r.blank? ? :default : r.to_sym
      end
      def translation(locale)
        {:text => self.text, :help_text => self.help_text}.with_indifferent_access.merge(
          (self.survey_section.survey.translation(locale)[:questions] || {})[self.reference_identifier] || {}
        )
      end

      private

      def imaged(text)
        self.display_type == "image" && !text.blank? ? ActionController::Base.helpers.image_tag(text) : text
      end

    end
  end
end
