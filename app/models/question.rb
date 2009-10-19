class Question < ActiveRecord::Base
  
  # Associations
  belongs_to :survey_section
  belongs_to :question_group
  has_many :answers # it might not always have answers
  has_one :dependency

  # Scopes
  default_scope :order => "display_order ASC"
  named_scope :in_order, {:order => "display_order ASC"}
  
  # Validations
  validates_presence_of :text, :survey_section_id, :display_order
  validates_inclusion_of :is_mandatory, :in => [true, false]
  
  # Instance Methods
  def initialize(*args)
    super(*args)
    default_args
  end
  
  def default_args
    self.is_mandatory ||= true
    self.display_type ||= "default"
    self.pick ||= "none"
  end
  
  def mandatory?
    self.is_mandatory == true
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
  
  def part_of_group?
    !self.question_group.nil?
  end

  def renderer(g = question_group)
    r = [g ? g.renderer.to_s : nil, display_type].compact.join("_")
    r.blank? ? :default : r.to_sym
  end
  
end