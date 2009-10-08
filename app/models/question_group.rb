class QuestionGroup < ActiveRecord::Base
  
  has_many :questions
  
  # Instance Methods
  def initialize(*args)
    super(*args)
    default_args
  end
  
  def default_args
    self.display_type = "inline"
  end

  def renderer
    display_type.blank? ? :default : display_type.to_sym
  end
end
