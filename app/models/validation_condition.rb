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
  
  # Class methods
  def self.operators
    OPERATORS
  end
  
  # Instance Methods
end