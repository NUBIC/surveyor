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

  def selected
    !self.new_record?
  end
  
  alias_method :selected?, :selected
  
  def selected=(value)
    true
  end

  #Method that returns the response as a particular response_class type
  def as(type_symbol)
    return case type_symbol.to_sym
    when :string
      self.string_value
    when :text
      self.text_value
    when :integer
      self.integer_value
    when :float
      self.float_value
    when :date
      self.datetime_value.nil? ? nil : self.datetime_value.to_date
    when :time
      self.datetime_value.nil? ? nil : self.datetime_value.to_time
    when :datetime
      self.datetime_value
    when :answer
      self.answer_id
    else
      self.answer_id
    end
  end
  
  def to_s
    if self.answer_id
      self.answer.text
    else
      "#{(self.string_value || self.text_value || self.integer_value || self.float_value).to_s}"
    end
    
  end
  
end
