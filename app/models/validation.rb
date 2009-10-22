class Validation < ActiveRecord::Base
  # Associations
  belongs_to :answer
  
  # Scopes
  
  # Validations
  validates_presence_of :rule
  validates_format_of :rule, :with => /^(?:and|or|\)|\(|[A-Z]|\s)+$/
  validates_numericality_of :answer_id
  
  # Instance Methods
end