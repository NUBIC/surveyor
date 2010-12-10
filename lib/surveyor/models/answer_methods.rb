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
        self.hide_label ||= false
        self.response_class ||= "answer"
        self.short_text ||= text
        self.data_export_identifier ||= Surveyor::Common.normalize(text)
      end
      
      def renderer(q = question)  
        r = [q.pick.to_s, self.response_class].compact.map(&:downcase).join("_")
        r.blank? ? :default : r.to_sym
      end
    end
  end
end