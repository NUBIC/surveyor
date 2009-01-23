class SurveySection < ActiveRecord::Base
  
  # Associations
  has_many :questions, :order => "display_order" # 0 or more
  belongs_to :survey
  
  # Validations
  validates_presence_of :title, :survey, :display_order
  
  def next
      SurveySection.find(:first, :conditions => ["display_order > ? and survey_id = ?",self.display_order, self.survey_id], :order => "display_order ASC")
  end
  
  def previous
      SurveySection.find(:first, :conditions => ["display_order < ?  and survey_id = ?",self.display_order, self.survey_id], :order => "display_order DESC")
  end
  
end

