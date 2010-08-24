class ResponseSet < ActiveRecord::Base

  # Associations
  belongs_to :survey
  belongs_to :user
  has_many :responses, :dependent => :destroy
  
  # Validations
  validates_presence_of :survey_id
  validates_associated :responses
  validates_uniqueness_of :access_code
  
  # Attributes
  attr_protected :completed_at
  attr_accessor :current_section_id

  # Callbacks
  after_update :save_responses
  
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
  
  def response_for(question_id, answer_id, group = nil)
    found = responses.detect{|r| r.question_id == question_id && r.answer_id == answer_id && r.response_group.to_s == group.to_s}
    found.blank? ? responses.new(:question_id => question_id, :answer_id => answer_id, :response_group => group) : found
  end
  
  def clear_responses
    question_ids = Question.find_all_by_survey_section_id(current_section_id).map(&:id)
    responses.select{|r| question_ids.include? r.question_id}.map(&:destroy)
    responses.reload
  end
  
  def response_attributes=(response_attributes)
    response_attributes.each do |question_id, responses_hash|
      # Response.delete_all(["response_set_id =? AND question_id =?", self.id, question_id])
      if (answer_id = responses_hash[:answer_id]) 
        if (!responses_hash[:answer_id].empty?) # Dropdowns return answer id but have an empty value if they are not set... ignoring those.
          #radio or dropdown - only one response
          responses.build({:question_id => question_id, :answer_id => answer_id, :survey_section_id => current_section_id}.merge(responses_hash[answer_id] || {}))
        end
      else
        #possibly multiples responses - unresponded radios end up here too
        # we use the variable question_id, not the "question_id" in the response_hash
        responses_hash.delete_if{|k,v| k == "question_id"}.each do |answer_id, response_hash|
          unless response_hash.delete_if{|k,v| v.blank?}.empty?
            responses.build({:question_id => question_id, :answer_id => answer_id, :survey_section_id => current_section_id}.merge(response_hash))
          end
        end
      end
    end
  end

  def response_group_attributes=(response_attributes)
    response_attributes.each do |question_id, responses_group_hash|
      # Response.delete_all(["response_set_id =? AND question_id =?", self.id, question_id])
      responses_group_hash.each do |response_group_number, group_hash|
        if (answer_id = group_hash[:answer_id]) # if group_hash has an answer_id key we treat it differently 
          if (!group_hash[:answer_id].empty?) # dropdowns return empty values in answer_ids if they are not selected
            #radio or dropdown - only one response
            responses.build({:question_id => question_id, :answer_id => answer_id, :response_group => response_group_number, :survey_section_id => current_section_id}.merge(group_hash[answer_id] || {}))
          end
        else
          #possibly multiples responses - unresponded radios end up here too
          # we use the variable question_id in the key, not the "question_id" in the response_hash... same with response_group key
          group_hash.delete_if{|k,v| (k == "question_id") or (k == "response_group")}.each do |answer_id, inner_hash|
            unless inner_hash.delete_if{|k,v| v.blank?}.empty?
              responses.build({:question_id => question_id, :answer_id => answer_id, :response_group => response_group_number, :survey_section_id => current_section_id}.merge(inner_hash))
            end
          end
        end
        
      end
    end
  end
  
  def save_responses
    responses.each{|response| response.save(false)}
  end

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

# responses

# "responses"=>{
#string   "6"=>{"question_id"=>"6", "20"=>{"string_value"=>"saf"}}, 
#text   "7"=>{"question_id"=>"7", "21"=>{"text_value"=>""}}, 
#radio+txt   "1"=>{"question_id"=>"1", "answer_id"=>"1", "4"=>{"string_value"=>""}}, 
#radio   "2"=>{"answer_id"=>"6"}, 
#radio   "3"=>{"answer_id"=>"10"}, 
#check   "4"=>{"question_id"=>"4", "answer_id"=>"15"}, 
#check+txt   "5"=>{"question_id"=>"5", "16"=>{"selected"=>"1"}, "19"=>{"string_value"=>""}}
#   },
# "survey_code"=>"test_survey", 
# "commit"=>"Next Section (Utensiles and you!) >>", 
# "authenticity_token"=>"8bee21081eea820ab1c658358c0baaa2e46de5d1", 
# "_method"=>"put", 
# "action"=>"update", 
# "controller"=>"app", 
# "response_set_code"=>"T2x8HhCQej", 
# "section"=>"2"

# response groups

# "24"=>{
#   "0"=>{"response_group"=>"0", "question_id"=>"24", "answer_id"=>"172"}, "1"=>{"response_group"=>"1", "question_id"=>"24", "answer_id"=>"173"}, 
#   "2"=>{"response_group"=>"2", "question_id"=>"24", "answer_id"=>""}, "3"=>{"response_group"=>"3", "question_id"=>"24", "answer_id"=>""}, 
#   "4"=>{"response_group"=>"4", "question_id"=>"24", "answer_id"=>""}},
#  where "24" is the question id

# Some other examples:
# "25"=>{
# "0"=>{"response_group"=>"0", "question_id"=>"25", "179"=>{"string_value"=>"camry"}}, 
# "1"=>{"response_group"=>"1", "question_id"=>"25", "179"=>{"string_value"=>"f150"}},
#  "2"=>{"response_group"=>"2", "question_id"=>"25", "179"=>{"string_value"=>""}}, 
#  "3"=>{"response_group"=>"3", "question_id"=>"25", "179"=>{"string_value"=>""}}, 
#  "4"=>{"response_group"=>"4", "question_id"=>"25", "179"=>{"string_value"=>""}}}, 
# 
# "26"=>{
# "0"=>{"response_group"=>"0", "question_id"=>"26", "180"=>{"string_value"=>"1999"}},
#  "1"=>{"response_group"=>"1", "question_id"=>"26", "180"=>{"string_value"=>"2004"}}, 
#  "2"=>{"response_group"=>"2", "question_id"=>"26", "180"=>{"string_value"=>""}}, 
#  "3"=>{"response_group"=>"3", "question_id"=>"26", "180"=>{"string_value"=>""}}, 
#  "4"=>{"response_group"=>"4", "question_id"=>"26", "180"=>{"string_value"=>""}}}, 
# 
# "27"=>{
# "0"=>{"182"=>{"integer_value"=>""}, "response_group"=>"0", "question_id"=>"27", "181"=>{"string_value"=>""}}, 
# "1"=>{"182"=>{"integer_value"=>""}, "response_group"=>"1", "question_id"=>"27", "181"=>{"string_value"=>""}},
#  "2"=>{"182"=>{"integer_value"=>""}, "response_group"=>"2", "question_id"=>"27", "181"=>{"string_value"=>""}}, 
#  "3"=>{"182"=>{"integer_value"=>""}, "response_group"=>"3", "question_id"=>"27", "181"=>{"string_value"=>""}}, 
#  "4"=>{"182"=>{"integer_value"=>""}, "response_group"=>"4", "question_id"=>"27", "181"=>{"string_value"=>""}}}},

# 0,1,2,3,4 are the response group numbers
# and anything else in the response group hash is handled normally