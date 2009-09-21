class CreateSurveySections < ActiveRecord::Migration
  def self.up
    create_table :survey_sections do |t|
      # Context
      t.integer :survey_id
      
      # Content
      t.string :title
      t.text :description

      # Display
      t.integer :display_order

      # Reference
      t.string :reference_identifier # Used to relate this question object to questions imported from a paper questionnaire 
      t.string :data_export_identifier # Used when referencing this quesiton in data export. Usually a shortend/cryptic version of the question text

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_sections
  end
end
