class Answer < ActiveRecord::Base

  # Scopes
  default_scope :order => "display_order ASC"
  
  # Associations
  belongs_to :question
  has_many :responses
  
  # Validations
  validates_presence_of :text
  validates_numericality_of :question_id, :allow_nil => false, :only_integer => true
  #validates_uniqueness_of :reference_identifier
  
  # Methods
  def pick
    self.question.pick == "none" ? nil : self.question.pick
  end
  def renderer
    group = question.question_group ? question.question_group.renderer.to_s : nil
    [group, self.pick, self.response_class].compact.empty? ? :default : [group, self.pick, self.response_class].compact.map(&:downcase).join("_").to_sym
  end
  
end
