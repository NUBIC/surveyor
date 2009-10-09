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
    when :string, :text, :integer, :float, :datetime
      self.send("#{type_symbol}_value".to_sym)
    when :date
      self.datetime_value.nil? ? nil : self.datetime_value.to_date
    when :time
      self.datetime_value.nil? ? nil : self.datetime_value.to_time
    else # :answer_id
      self.answer_id
    end
  end
  
  def to_s
    if self.answer.response_class == "answer" and self.answer_id
      return self.answer.text
    else
      return "#{(self.string_value || self.text_value || self.integer_value || self.float_value || nil).to_s}"
    end
  end
  
end
