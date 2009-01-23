class DependencyCondition < ActiveRecord::Base
  # Constants
  OPERATORS = %w(== != < > <= >=) # CONSTANT or @@class_variable when validations listed before class method

  # Associations
  belongs_to :answer
  belongs_to :dependency
  belongs_to :dependent_question, :foreign_key => :question_id, :class_name => :question

  # Validations
  validates_numericality_of :dependency_id, :question_id, :answer_id
  validates_presence_of :operator, :rule_key
  validates_inclusion_of :operator, :in => OPERATORS
  validates_uniqueness_of :rule_key, :scope => :dependency_id

  # Class methods
  def self.operators
    OPERATORS
  end

  # Evaluates the condition on the response_set
  def evaluation_of(response_set)
    response = response_set.find_response(self.answer_id) || false # turns out eval("nil and false") => nil so we need to return false if no response is found
    return(response and self.is_satisfied_by?(response))
  end

  # Checks to see if the response passed in satisfies the dependency condition
  def is_satisfied_by?(response)
    response_class = response.answer.response_class 
    return case self.operator
    when "=="
      response.as(response_class) == self.as(response_class)
    when "!="
      response.as(response_class) != self.as(response_class)
    when "<"
      response.as(response_class) < self.as(response_class)
    when ">"
      response.as(response_class) > self.as(response_class)
    when "<="
      response.as(response_class) <= self.as(response_class)
    when ">="
      response.as(response_class) >= self.as(response_class)
    else
      false
    end
  end

  # Method that returns the dependency as a particular response_class type
  def as(type_symbol)
    return case type_symbol.to_sym
    when :string
      self.string_value
    when :text
      self.text_value
    when :integer
      self.integer_value
    when :float
      self.float_value
    when :answer
      self.answer_id
    else
      self.answer_id
    end
  end
  
  # The hash used in the dependency parent object to evaluate its rule string
  def to_evaluation_hash(response_set)
    {self.symbol_key => self.evaluation_of(response_set)}
  end
  
  # Returns the rule key to be used in the subsitution string in the parent depenedency object
  def symbol_key
    self.rule_key.to_sym
  end

end
