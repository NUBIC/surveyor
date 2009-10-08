class Answer < ActiveRecord::Base
  
  # Associations
  belongs_to :question
  has_many :responses

  # Scopes
  default_scope :order => "display_order ASC"
  
  # Validations
  validates_presence_of :text
  validates_numericality_of :question_id, :allow_nil => false, :only_integer => true
  #validates_uniqueness_of :reference_identifier
  
  # Methods
  def renderer(q = question)  
    r = [q.pick.to_s, self.response_class].compact.join("_")
    r.blank? ? :default : r.to_sym
  end
  
end
