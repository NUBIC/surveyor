module SurveyParser
  class ValidationCondition < SurveyParser::Base
    # Context, Conditional, Value, Reference
    attr_accessor :id, :validation_id, :rule_key, :parser
    attr_accessor :operator
    attr_accessor :question_id, :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other, :regexp
    attr_accessor :question_reference, :answer_reference
  
    def default_options
      { :operator => "==" }
    end
    def parse_args(args)
      a0, a1 = args
      {:operator => a0}.merge(a1 || {})
    end
    def parse_opts(opts)
      {:rule_key => opts[:reference_identifier]}
    end
    
  end
end