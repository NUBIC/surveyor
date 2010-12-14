module Surveyor
  module Models
    module ResponseSetMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :survey
        base.send :belongs_to, :user
        base.send :has_many, :responses, :dependent => :destroy
        base.send :accepts_nested_attributes_for, :responses, :allow_destroy => true
        
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :survey_id
          base.send :validates_associated, :responses
          base.send :validates_uniqueness_of, :access_code
          
          @@validations_already_included = true
        end

        # Attributes
        base.send :attr_protected, :completed_at
        base.send :attr_accessor, :current_section_id
        
        # Class methods
        base.instance_eval do
          def reject_or_delete_blanks(hash_of_hashes)
            result = {}
            hash_of_hashes.each_pair do |k, hash|
              if has_blank_value?(hash)
                result.merge!({k => hash.merge("_delete" => "true")}) if hash.has_key?("id")
              else
                result.merge!({k => hash})
              end
            end
            result
          end
          def has_blank_value?(hash)
            hash.any?{|k,v| v.is_a?(Array) ? v.all?{|x| x.to_s.blank?} : v.to_s.blank?}
          end
        end
      end

      # Instance methods
      def initialize(*args)
        super(*args)
        default_args
      end

      def default_args
        self.started_at ||= Time.now
        self.access_code = Surveyor::Common.make_tiny_code
      end

      def access_code=(val)
        while ResponseSet.find_by_access_code(val)
          val = Surveyor::Common.make_tiny_code
        end
        super
      end

      def to_csv
        qcols = Question.content_columns.map(&:name) - %w(created_at updated_at)
        acols = Answer.content_columns.map(&:name) - %w(created_at updated_at)
        rcols = Response.content_columns.map(&:name)
        require 'fastercsv'
        FCSV(result = "") do |csv|
          csv << qcols.map{|qcol| "question.#{qcol}"} + acols.map{|acol| "answer.#{acol}"} + rcols.map{|rcol| "response.#{rcol}"}
          responses.each do |response|
            csv << qcols.map{|qcol| response.question.send(qcol)} + acols.map{|acol| response.answer.send(acol)} + rcols.map{|rcol| response.send(rcol)}
          end
        end
        result
      end

      # def response_group_attributes=(response_attributes)
      #   response_attributes.each do |question_id, responses_group_hash|
      #     # Response.delete_all(["response_set_id =? AND question_id =?", self.id, question_id])
      #     responses_group_hash.each do |response_group_number, group_hash|
      #       if (answer_id = group_hash[:answer_id]) # if group_hash has an answer_id key we treat it differently 
      #         if (!group_hash[:answer_id].empty?) # dropdowns return empty values in answer_ids if they are not selected
      #           #radio or dropdown - only one response
      #           responses.build({:question_id => question_id, :answer_id => answer_id, :response_group => response_group_number, :survey_section_id => current_section_id}.merge(group_hash[answer_id] || {}))
      #         end
      #       else
      #         #possibly multiples responses - unresponded radios end up here too
      #         # we use the variable question_id in the key, not the "question_id" in the response_hash... same with response_group key
      #         group_hash.delete_if{|k,v| (k == "question_id") or (k == "response_group")}.each do |answer_id, inner_hash|
      #           unless inner_hash.delete_if{|k,v| v.blank?}.empty?
      #             responses.build({:question_id => question_id, :answer_id => answer_id, :response_group => response_group_number, :survey_section_id => current_section_id}.merge(inner_hash))
      #           end
      #         end
      #       end
      # 
      #     end
      #   end
      # end

      def complete!
        self.completed_at = Time.now
      end

      def correct?
        responses.all?(&:correct?)
      end
      def correctness_hash
        { :questions => survey.sections_with_questions.map(&:questions).flatten.compact.size,
          :responses => responses.compact.size,
          :correct => responses.find_all(&:correct?).compact.size
        }
      end
      def mandatory_questions_complete?
        progress_hash[:triggered_mandatory] == progress_hash[:triggered_mandatory_completed]
      end
      def progress_hash
        qs = survey.sections_with_questions.map(&:questions).flatten
        ds = dependencies(qs.map(&:id))
        triggered = qs - ds.select{|d| !d.is_met?(self)}.map(&:question)
        { :questions => qs.compact.size,
          :triggered => triggered.compact.size,
          :triggered_mandatory => triggered.select{|q| q.mandatory?}.compact.size,
          :triggered_mandatory_completed => triggered.select{|q| q.mandatory? and is_answered?(q)}.compact.size
        }
      end
      def is_answered?(question)
        %w(label image).include?(question.display_type) or !is_unanswered?(question)
      end
      def is_unanswered?(question)
        self.responses.detect{|r| r.question_id == question.id}.nil?
      end

      # Returns the number of response groups (count of group responses enterted) for this question group
      def count_group_responses(questions)
        questions.map{|q| responses.select{|r| (r.question_id.to_i == q.id.to_i) && !r.response_group.nil?}.group_by(&:response_group).size }.max
      end

      def unanswered_dependencies
        dependencies.select{|d| d.is_met?(self) and self.is_unanswered?(d.question)}.map(&:question)
      end

      def all_dependencies
        arr = dependencies.partition{|d| d.is_met?(self) }
        {:show => arr[0].map{|d| d.question_group_id.nil? ? "question_#{d.question_id}" : "question_group_#{d.question_group_id}"}, :hide => arr[1].map{|d| d.question_group_id.nil? ? "question_#{d.question_id}" : "question_group_#{d.question_group_id}"}}
      end

      # Check existence of responses to questions from a given survey_section
      def no_responses_for_section?(section)
        self.responses.count(:conditions => {:survey_section_id => section.id}) == 0
      end

      protected

      def dependencies(question_ids = nil)
        question_ids ||= Question.find_all_by_survey_section_id(current_section_id).map(&:id)
        depdendecy_ids = DependencyCondition.all(:conditions => {:question_id => question_ids}).map(&:dependency_id)
        Dependency.find(depdendecy_ids, :include => :dependency_conditions)
      end
    end
  end
end