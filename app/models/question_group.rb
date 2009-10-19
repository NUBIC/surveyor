class QuestionGroup < ActiveRecord::Base
  
  has_many :questions
  has_one :dependency
  
  # Instance Methods
  def initialize(*args)
    super(*args)
    default_args
  end
  
  def default_args
    self.display_type ||= "inline"
  end

  def renderer
    display_type.blank? ? :default : display_type.to_sym
  end
  
  def dependent?
    self.dependency != nil
  end
  def triggered?(response_set)
    dependent? ? self.dependency.met?(response_set) : true
  end
  def dep_class(response_set)
    dependent? ? triggered?(response_set) ? "dependent" : "hidden dependent" : nil
  end
  
end
