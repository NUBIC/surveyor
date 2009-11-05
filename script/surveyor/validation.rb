class Validation < SurveyParser::Base
  
  # Context, Conditional, Children
  attr_accessor :id, :answer_id, :parser
  attr_accessor :rule, :message
  attr_accessor :validation_conditions
  
  def default_options
    {:rule => "A"}
  end
  def parse_args(args)
    args[0] || {}
  end
    
end