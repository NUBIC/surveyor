require 'surveyor/common'
module Surveyor
  module Models
    module AnswerMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include MustacheContext
      include ActiveModel::ForbiddenAttributesProtection
      include CustomModelNaming

      included do
        # Associations
        belongs_to :question, required: false
        has_many :responses
        has_many :validations, dependent: :destroy
        attr_accessible *PermittedParams.new.answer_attributes if defined? ActiveModel::MassAssignmentSecurity

        # Validations
        validates_presence_of :text
        validates_inclusion_of :qualify_logic, in: ["must", "may", "reject"]

        self.param_key = :a
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.is_exclusive ||= false
        self.display_type ||= "default"
        self.response_class ||= "answer"
        self.short_text ||= text
        self.data_export_identifier ||= Surveyor::Common.normalize(text)
        self.api_id ||= Surveyor::Common.generate_api_id
        self.qualify_logic ||= "may"
      end
      def display_type=(val)
        write_attribute(:display_type, val.nil? ? nil : val.to_s)
      end
      def dom_class(response_set = nil)
        ['form_group', (response_class unless response_class == "answer"), ("exclusive" if is_exclusive), custom_class].compact.join(" ")
      end
      def css_class(response_set = nil)
        dom_class(response_set)
      end

      def text_for(position = nil, context = nil, locale = nil)
        output = imaged(split(in_context(translation(locale)[:text], context), position))
        (output.blank? or display_type == "hidden_label") ? false : output
      end
      def help_text_for(context = nil, locale = nil)
        in_context(translation(locale)[:help_text], context)
      end
      def default_value_for(context = nil, locale = nil)
        in_context(translation(locale)[:default_value], context)
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
      def translation(locale)
        {:text => self.text, :help_text => self.help_text, :default_value => self.default_value}.with_indifferent_access.merge(
          (self.question.translation(locale)[:answers] || {})[self.reference_identifier] || {}
        )
      end

      private

      def imaged(text)
        self.display_type == "image" && !text.blank? ? ActionController::Base.helpers.image_tag(text) : text
      end
    end
  end
end
