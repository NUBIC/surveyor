require 'uuid'

module Surveyor
  module Models
    module AnswerMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :question
        base.send :has_many, :responses
        base.send :has_many, :validations, :dependent => :destroy
        
        # Scopes
        base.send :default_scope, :order => "display_order ASC"
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :text
          # this causes issues with building and saving
          # base.send :validates_numericality_of, :question_id, :allow_nil => false, :only_integer => true
          @@validations_already_included = true
        end
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.display_order ||= self.question ? self.question.answers.count : 0
        self.is_exclusive ||= false
        self.display_type ||= "default"
        self.response_class ||= "answer"
        self.short_text ||= text
        self.data_export_identifier ||= Surveyor::Common.normalize(text)
        self.api_id ||= UUID.generate
      end
      
      def css_class
        [(is_exclusive ? "exclusive" : nil), custom_class].compact.join(" ")
      end
      
      def split_or_hidden_text(part = nil)
        return "" if display_type == "hidden_label"
        part == :pre ? text.split("|",2)[0] : (part == :post ? text.split("|",2)[1] : text)
      end
      
      def api_json
        {:text => split_or_hidden_text(:pre), :uuid => api_id}\
          .merge(split_or_hidden_text(:post).blank? ? {} : {:post_text => split_or_hidden_text(:post)})\
          .merge(response_class == "answer" ? {} : {:type => response_class})\
          .merge(is_exclusive == false ? {} : {:exclusive => is_exclusive})
      end
      
    end
  end
end