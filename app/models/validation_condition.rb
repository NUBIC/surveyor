class ValidationCondition < ActiveRecord::Base
  # Constants
  OPERATORS = %w(== != < > <= >= =~)

  # Associations
  belongs_to :validation
  
  # Scopes
  
  # Validations
  validates_numericality_of :validation_id #, :question_id, :answer_id
  validates_presence_of :operator, :rule_key
  validates_inclusion_of :operator, :in => OPERATORS
  validates_uniqueness_of :rule_key, :scope => :validation_id
  
  acts_as_response # includes "as" instance method
  
  # Class methods
  def self.operators
    OPERATORS
  end
  
  # Instance Methods
  def to_hash(response)
    {rule_key.to_sym => (response.nil? ? false : self.is_valid?(response))}
  end
  
  def is_valid?(response)
    klass = response.answer.response_class
    case self.operator
    when "==", "<", ">", "<=", ">="
      response.as(klass).send(self.operator, self.as(klass))
    when "!="
      !(response.as(klass) == self.as(klass))
    when "=~"
      !(response.as(klass).to_s =~ Regexp.new(self.regexp || "")).nil?
    else
      false
    end
  end
end
