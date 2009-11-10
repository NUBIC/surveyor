module SurveyParser
  class Validation < SurveyParser::Base
  
    # Context, Conditional, Children
    attr_accessor :id, :answer_id, :parser
    attr_accessor :rule, :message
    has_children :validation_conditions
  
  
    def default_options
      {:rule => "A"}
    end
    def parse_args(args)
      args[0] || {}
    end
    def parse_opts(opts)
      {} # toss the method name and reference identifier by default
    end
    
  end
end