require 'fastercsv'
require 'csv'
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

        # Class methods
        base.instance_eval do
          def to_savable(hash_of_hashes)
            result = []
            (hash_of_hashes || {}).each_pair do |k, hash|
              hash = Response.applicable_attributes(hash)
              if has_blank_value?(hash)
                result << hash.merge!({:_destroy => '1'}).except('answer_id') if hash.has_key?('id')
              else
                result << hash
              end
            end
            result
          end

          def has_blank_value?(hash)
            return true if hash["answer_id"].blank?
            return false if (q = Question.find_by_id(hash["question_id"])) and q.pick == "one"
            hash.any?{|k,v| v.is_a?(Array) ? v.all?{|x| x.to_s.blank?} : v.to_s.blank?}
          end

          def trim_for_lookups(hash_of_hashes)
            result = {}
            (reject_or_destroy_blanks(hash_of_hashes) || {}).each_pair do |k, hash|
              result.merge!({k => {"question_id" => hash["question_id"], "answer_id" => hash["answer_id"]}.merge(hash.has_key?("response_group") ? {"response_group" => hash["response_group"]} : {} ).merge(hash.has_key?("id") ? {"id" => hash["id"]} : {} ).merge(hash.has_key?("_destroy") ? {"_destroy" => hash["_destroy"]} : {} )})
            end
            result
          end

          private
            def reject_or_destroy_blanks(hash_of_hashes)
              result = {}
              (hash_of_hashes || {}).each_pair do |k, hash|
                hash = Response.applicable_attributes(hash)
                if has_blank_value?(hash)
                  result.merge!({k => hash.merge("_destroy" => "true")}) if hash.has_key?("id")
                else
                  result.merge!({k => hash})
                end
              end
              result
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
        self.access_code ||= random_unique_access_code
        self.api_id ||= Surveyor::Common.generate_api_id
      end
      
      def random_unique_access_code
        val = Surveyor::Common.make_tiny_code
        while ResponseSet.find_by_access_code(val)
          val = Surveyor::Common.make_tiny_code
        end
        val
      end
      private :random_unique_access_code

      def to_csv(access_code = false, print_header = true)
        qcols = Question.content_columns.map(&:name) - %w(created_at updated_at)
        acols = Answer.content_columns.map(&:name) - %w(created_at updated_at)
        rcols = Response.content_columns.map(&:name)
        csvlib = CSV.const_defined?(:Reader) ? FasterCSV : CSV
        result = csvlib.generate do |csv|
          csv << (access_code ? ["response set access code"] : []) + qcols.map{|qcol| "question.#{qcol}"} + acols.map{|acol| "answer.#{acol}"} + rcols.map{|rcol| "response.#{rcol}"} if print_header
          responses.each do |response|
            csv << (access_code ? [self.access_code] : []) + qcols.map{|qcol| response.question.send(qcol)} + acols.map{|acol| response.answer.send(acol)} + rcols.map{|rcol| response.send(rcol)}
          end
        end
        result
      end
      
      def as_json(options = nil)
        template_path = ActionController::Base.view_paths.find("show", ["surveyor"], false, {:handlers=>[:rabl], :locale=>[:en], :formats=>[:json]}, [], []).inspect
        engine = Rabl::Engine.new(File.read(template_path))
        engine.to_hash((options || {}).merge(:object => self))
      end
      
      def complete!
        self.completed_at = Time.now
      end

      def complete?
        !completed_at.nil?
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
      def is_group_unanswered?(group)
        group.questions.any?{|question| is_unanswered?(question)}
      end

      # Returns the number of response groups (count of group responses enterted) for this question group
      def count_group_responses(questions)
        questions.map{|q| responses.select{|r| (r.question_id.to_i == q.id.to_i) && !r.response_group.nil?}.group_by(&:response_group).size }.max
      end

      def unanswered_dependencies
        unanswered_question_dependencies + unanswered_question_group_dependencies
      end

      def unanswered_question_dependencies
        dependencies.select{ |d| d.question && self.is_unanswered?(d.question) && d.is_met?(self) }.map(&:question)
      end

      def unanswered_question_group_dependencies
        dependencies.select{ |d| d.question_group && self.is_group_unanswered?(d.question_group) && d.is_met?(self) }.map(&:question_group)
      end

      def all_dependencies(question_ids = nil)
        arr = dependencies(question_ids).partition{|d| d.is_met?(self) }
        {:show => arr[0].map{|d| d.question_group_id.nil? ? "q_#{d.question_id}" : "g_#{d.question_group_id}"}, :hide => arr[1].map{|d| d.question_group_id.nil? ? "q_#{d.question_id}" : "g_#{d.question_group_id}"}}
      end

      # Check existence of responses to questions from a given survey_section
      def no_responses_for_section?(section)
        !responses.any?{|r| r.survey_section_id == section.id}
      end

      protected

      def dependencies(question_ids = nil)
        deps = Dependency.all(:include => :dependency_conditions, :conditions => {:dependency_conditions => {:question_id => question_ids || responses.map(&:question_id)}})
        # this is a work around for a bug in active_record in rails 2.3 which incorrectly eager-loads associatins when a condition clause includes an association limiter
        deps.each{|d| d.dependency_conditions.reload}
        deps
      end
    end
  end
end
