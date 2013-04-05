require 'surveyor/common'

module Surveyor
  module Models
    module QuestionGroupMethods
      def self.included(base)
        # Associations
        base.send :has_many, :questions
        base.send :has_one, :dependency

        # Whitelisting attributes
        base.send :attr_accessible, :text, :help_text, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :display_type, :custom_class, :custom_renderer
      end

      include MustacheContext

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.display_type ||= "inline"
        self.api_id ||= Surveyor::Common.generate_api_id
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

      def part_of_group?
      end

      def translation(locale)
        questions = self.questions
        text_hash = {:text => self.text,
                    :help_text => self.help_text}.with_indifferent_access
        if ! questions.empty?
          text_hash.merge(
            (questions.first.survey_section.survey.translation(locale)[:question_groups] || {})[self.reference_identifier] || {}
        )
        else
          text_hash
        end
      end

      private

      def imaged(text)
        self.display_type == "image" && !text.blank? ? ActionController::Base.helpers.image_tag(text) : text
      end
    end
  end
end
