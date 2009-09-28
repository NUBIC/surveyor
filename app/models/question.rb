class Question < ActiveRecord::Base
  
  # Associations
  belongs_to :survey_section
  belongs_to :question_group
  has_many :answers # it might not always have answers
  has_one :dependency
  
  # Validations
  validates_presence_of :text, :survey_section_id, :display_order
  validates_inclusion_of :is_mandatory, :in => [true, false]
  
  # Instance Methods
  def initialize(*args)
    super(*args)
    default_args
  end
  
  def default_args
    # self.is_active ||= false
    self.is_mandatory ||= true
  end
  
  def mandatory?
    self.is_mandatory == true
  end
  
  def display_type
    super || "default"
  end
  
  def has_dependency?
    self.dependency != nil
  end
  
  def dependency_satisfied?(response_set)
    self.has_dependency? and self.dependency.met?(response_set)
  end
  
  def part_of_group?
    !self.question_group.nil?
  end

  def renderer
    [(question_group ? question_group.renderer.to_s : nil), display_type].compact.join("_").to_sym
  end
  
end