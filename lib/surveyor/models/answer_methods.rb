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

      def data_rules
        #create data rules for validations, see 'lib/assets/javascripts/surveyor/jquery.validate.js:887'
        case response_class
          when 'integer'        then integer_conditions
          when 'text', 'string' then text_conditions
        end
      end

      def integer_conditions
        rules = {}
        validations.map{ |v| v.validation_conditions }.flatten.each do |condition|
          case condition.operator
          when "<=" then rules.merge!({ 'rule-max'     => condition.integer_value })
          when "<"  then rules.merge!({ 'rule-max'     => ( condition.integer_value + 1 ) })
          when ">"  then rules.merge!({ 'rule-min'     => ( condition.integer_value - 1 ) })
          when ">=" then rules.merge!({ 'rule-min'     => condition.integer_value })
          when "==" then rules.merge!({ 'rule-equalto' => condition.integer_value })
          end
        end
        rules
      end

      def text_conditions
        rules = {}
        validations.map{ |v| v.validation_conditions }.flatten.each do |condition|
          case condition.operator
          when "=~" then rules.merge!({ 'rule-pattern' => condition.regexp })
          end
        end
        rules
      end

      def image_type?
        self.display_type == "image" && text.present?
      end

      private

      def imaged(text)
        spanned_text = if image_type?
          image = ActionController::Base.helpers.image_tag(text)
          short_text != text ? ( short_text.to_s + image ) : image
        else
          text
        end
        span_wrapper spanned_text
      end

      def span_wrapper text
        "<span>#{text}</span>" if %(one any).include?( question.pick )
      end
    end
  end
end

