class QuestionGroup < ActiveRecord::Base
  
  has_many :questions
  
  def renderer
    display_type.blank? ? :default : display_type.to_sym
  end
end
