class SurveySection < ActiveRecord::Base
  
  # Extending surveyor
  include "#{self.name}Extensions".constantize if Surveyor::Config['extend'].include?(self.name.underscore)
    
  # Associations
  has_many :questions, :order => "display_order ASC"
  belongs_to :survey
  
  # Scopes
  default_scope :order => "display_order ASC"
  named_scope :with_includes, { :include => {:questions => [:answers, :question_group, {:dependency => :dependency_conditions}]}}
  
  # Validations
  validates_presence_of :title, :survey, :display_order
  
end

