module Surveyor
  module Models
    module SurveySectionMethods
      def self.included(base)
        # Associations
        base.send :has_many, :questions, :order => "display_order ASC", :dependent => :destroy
        base.send :belongs_to, :survey

        # Scopes
        base.send :default_scope, :order => "display_order ASC"
        base.send :named_scope, :with_includes, { :include => {:questions => [:answers, :question_group, {:dependency => :dependency_conditions}]}}

        # Validations
        base.send :validates_presence_of, :title, :survey, :display_order
      end

      # Instance Methods

    end
  end
end