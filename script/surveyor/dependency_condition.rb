class DependencyCondition

  # Context, Conditional, Value
  attr_accessor :id, :dependency_id, :rule_key, :parser
  attr_accessor :question_id, :operator
  attr_accessor :answer_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other
  attr_accessor :question_reference, :answer_reference
  
  # id, dependency, and question_id required
  def initialize(dependency, args, options)
    self.parser = dependency.parser
    self.id = parser.new_dependency_condition_id
    self.dependency_id = dependency.id
    args_options = parse_args_options(args)
    self.default_options().merge(options).merge(args_options).each{|key,value| self.instance_variable_set("@#{key}", value)}
  end
  
  def default_options()
    { :operator => "==" }
  end
  
  def parse_args_options(args)
    a0, a1, a2 = args
    options = {:question_reference => a0.to_s.gsub("q_", ""), :operator => a1}
    a2.is_a?(Hash) ? options.merge(a2) : options.merge({:answer_reference => a2.to_s.gsub("a_", "")})
  end
  
  def yml_attrs
    instance_variables.sort - ["@parser", "@question_reference", "@answer_reference", "@reference_identifier"]
  end
  def to_yml
    out = [ %(#{@data_export_identifier}_#{@id}:) ]
    yml_attrs.each{|a| out << "  #{a[1..-1]}: #{instance_variable_get(a).is_a?(String) ? "\"#{instance_variable_get(a)}\"" : instance_variable_get(a) }"}
    (out << nil ).join("\r\n")
  end

  def reconcile_dependencies
    # Looking up references to questions and answers for linking the dependency objects
    puts "Looking up question: #{@question_reference}"
    if (ref_question = Survey.current_survey.find_question_by_reference(@question_reference)) # TODO change this. Argh. I can't think of a better way to get a hold of this reference here...
      puts "  found question: #{ref_question.text} (id:#{ref_question.id})"
      @question_id = ref_question.id
      puts "Looking up answer: #{@answer_reference}"
      if (ref_answer = ref_question.find_answer_by_reference(@answer_reference))
        puts "  found answer: '#{ref_answer.text}' (id:#{ref_answer.id})"
        @answer_id = ref_answer.id
      else
        raise "Could not find referenced answer #{@answer_reference}"
      end
    else
      raise "Could not find referenced question #{@question_reference}"
    end
  end

  def to_file
    # Reconciling the references used in the dsl to actual object ids
    #puts "Reconcile of dependency:"
   # reconcile_dependencies    
    File.open(self.parser.dependency_conditions_yml, File::CREAT|File::APPEND|File::WRONLY) {|f| f << to_yml}
  end

end