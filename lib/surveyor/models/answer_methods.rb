require 'surveyor/common'

module Surveyor
  module Models
    module AnswerMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :question
        base.send :has_many, :responses
        base.send :has_many, :validations, :dependent => :destroy

        # Scopes
        base.send :default_scope, :order => "#{base.quoted_table_name}.display_order ASC"

        # Mustache
        base.send :include, MustacheContext

        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :text
          # this causes issues with building and saving
          # base.send :validates_numericality_of, :question_id, :allow_nil => false, :only_integer => true
          @@validations_already_included = true
        end

        # Whitelisting attributes
        base.send :attr_accessible, :question, :question_id, :text, :short_text, :help_text, :weight, :response_class, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :display_order, :is_exclusive, :display_length, :custom_class, :custom_renderer, :default_value, :display_type, :input_mask, :input_mask_placeholder
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

      private

      def imaged(text)
        self.display_type == "image" && !text.blank? ? ActionController::Base.helpers.image_tag(text) : text
      end
    end
  end
end

