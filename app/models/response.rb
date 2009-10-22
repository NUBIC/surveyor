class Response < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
         
  # Associations
  belongs_to :response_set
  belongs_to :question
  belongs_to :answer
  
  # Validations
  validates_presence_of :response_set_id, :question_id, :answer_id
  
  # Named scopes
  named_scope :in_section, lambda {|section_id| {:include => :question, :conditions => ['questions.survey_section_id =?', section_id.to_i ]}}

  acts_as_response # includes "as" instance method

  def selected
    !self.new_record?
  end
  
  alias_method :selected?, :selected
  
  def selected=(value)
    true
  end
  
  def to_s
    if self.answer.response_class == "answer" and self.answer_id
      return self.answer.text
    else
      return "#{(self.string_value || self.text_value || self.integer_value || self.float_value || nil).to_s}"
    end
  end
  
end
