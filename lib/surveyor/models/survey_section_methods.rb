module Surveyor
  module Models
    module SurveySectionMethods
      def self.included(base)
        # Associations
        base.send :has_many, :questions, :order => "display_order ASC", :dependent => :destroy
        base.send :belongs_to, :survey

        # Scopes
        base.send :default_scope, :order => "display_order ASC"
        base.send :scope, :with_includes, { :include => {:questions => [:answers, :question_group, {:dependency => :dependency_conditions}]}}
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :title, :display_order
          # this causes issues with building and saving
          #, :survey
          
          @@validations_already_included = true
        end
      end

      # Instance Methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.display_order ||= survey ? survey.sections.count : 0
        self.data_export_identifier ||= Surveyor::Common.normalize(title)
      end
      
      def api_json
        qs = []
        {:title => title, :questions_and_groups => questions.each_with_index.map do |q,i|
          if q.part_of_group?
            qs << q
            if (i+1 >= questions.size) or (q.question_group_id != questions[i+1].question_group_id)
              q.question_group.api_json(qs)
              qs = []
            end
          else
            q.api_json
          end
        end
        }
      end
    end
  end
end