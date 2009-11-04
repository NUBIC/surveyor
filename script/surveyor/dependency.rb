class Dependency < Surveyor::Base
  # Context, Conditional, Children
  attr_accessor :id, :question_id, :question_group_id, :parser
  attr_accessor :rule
  has_children :dependency_conditions

  def parse_opts(opts)
    {} # toss the method name and reference identifier by default
  end

end