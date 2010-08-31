class Answer < ActiveRecord::Base

  # Associations
  belongs_to :question
  has_many :responses
  has_many :validations, :dependent => :destroy

  # Scopes
  default_scope :order => "display_order ASC"
  
  # Validations
  validates_presence_of :text
  validates_numericality_of :question_id, :allow_nil => false, :only_integer => true
  
  # Methods
  def renderer(q = question)  
    r = [q.pick.to_s, self.response_class].compact.map(&:downcase).join("_")
    r.blank? ? :default : r.to_sym
  end
  
end
