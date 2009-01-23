class Answer < ActiveRecord::Base

  # Associations
  belongs_to :question
  has_many :responses
  
  # Validations
  validates_presence_of :text
  validates_numericality_of :question_id, :allow_nil => false, :only_integer => true
  #validates_uniqueness_of :reference_identifier
  
  # Methods
  def partial_name
    [(self.question.pick == "none")? nil : self.question.pick.downcase, self.response_class.downcase].compact.join("_")
  end

  
end
