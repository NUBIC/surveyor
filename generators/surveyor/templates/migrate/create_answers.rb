class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      # Context
      t.integer :question_id

      # Content
      t.text :text
      t.text :short_text #Used for presenting responses to experts (ie non-survey takers). Just a shorted version of the string
      t.text :help_text
      t.integer :weight # Used to assign a weight to an answer object (used for computing surveys that have numerical results) (I added this to support the Urology questionnaire -BLC)
      
      # Display
      t.string :response_class # What kind of additional data does this answer accept?
      t.integer :display_order
      t.boolean :is_exclusive # If set it causes some UI trigger to remove (and disable) all the other answer choices selected for a question (needed for the WHR)
      t.boolean :hide_label 
      
      # Reference
      t.string :reference_identifier # Used to relate this question object to questions imported from a paper questionnaire 
      t.string :data_export_identifier # Used when referencing this quesiton in data export. Usually a shortend/cryptic version of the question text
      t.string :common_data_identitier # Used to share data across surveys (or perhaps map to a common vocab.)
      
      # Validations
      # the response_class attr also has validation implications (int, string, float,etc..) but these attrs below give fine grain control over responses
      t.integer :max_value
      t.integer :min_value
      t.integer :length # number of chars/ints accepted
      t.integer :decimal_precision # only for floats
      t.boolean :allow_negative # only for numeric values
      t.boolean :allow_blank
      t.string :unit # a string representation of the unit (lbs. USD, oz.) - Context is from the survey domain and question
      
      # Display property
      t.integer :display_length # if smaller than answer.length the html input length will be this value
      
      t.timestamps
      
    end
  end

  def self.down
    drop_table :answers
  end
end
