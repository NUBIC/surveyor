module Surveyor
  module Models
    module SurveySectionMethods
      def self.included(base)
        # Associations
        base.send :has_many, :questions, :order => "display_order ASC", :dependent => :destroy
        base.send :belongs_to, :survey

        # Scopes
        base.send :scope, :with_includes, { :include => {:questions => [:answers, :question_group, {:dependency => :dependency_conditions}]}}

        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :title, :display_order
          # this causes issues with building and saving
          #, :survey

          @@validations_already_included = true
        end

        # Whitelisting attributes
        base.send :attr_accessible, :survey, :survey_id, :title, :description, :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier, :display_order, :custom_class
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.data_export_identifier ||= Surveyor::Common.normalize(title)
      end

      def questions_and_groups
        qs = []
        questions.each_with_index.map do |q,i|
          if q.part_of_group?
            if (i+1 >= questions.size) or (q.question_group_id != questions[i+1].question_group_id)
              q.question_group
            end
          else
            q
          end
        end.compact
      end

      def translation(locale)
        {:title => self.title, :description => self.description}.with_indifferent_access.merge(
          (self.survey.translation(locale)[:survey_sections] || {})[self.reference_identifier] || {}
        )
      end
    end
  end
end