class QuestionGroup < ActiveRecord::Base
  
  has_many :questions
  
  def renderer
    display_type.to_sym || :default
  end
end
