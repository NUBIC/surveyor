require 'surveyor/common'
module Surveyor
  module Models
    module AnswerMethods
      extend ActiveSupport::Concern
      include ActiveModel::Validations
      include MustacheContext
      include ActiveModel::ForbiddenAttributesProtection

      included do
        # Associations
        belongs_to :question
        has_many :responses
        has_many :validations, :dependent => :destroy
        attr_accessible *PermittedParams.new.answer_attributes if defined? ActiveModel::MassAssignmentSecurity

        # Validations
        validates_presence_of :text
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
      end
      def display_type=(val)
        write_attribute(:display_type, val.nil? ? nil : val.to_s)
      end

      def css_class
        [(is_exclusive ? "exclusive" : nil), custom_class].compact.join(" ")
      end

      def text_for(position = nil, context = nil, locale = nil)
        return "" if display_type == "hidden_label"
        imaged(split(in_context(translation(locale)[:text], context), position))
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
