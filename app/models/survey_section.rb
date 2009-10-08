class SurveySection < ActiveRecord::Base
  
  # Associations
  has_many :questions
  belongs_to :survey
  
  # Scopes
  default_scope :order => "display_order ASC"
  named_scope :with_includes, { :include => {:questions => [{:answers => :question}, :dependency]}}
  
  # Validations
  validates_presence_of :title, :survey, :display_order
  
end

