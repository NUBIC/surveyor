class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      # Context
      t.integer :survey_section_id

      # Content
      t.text :text
      t.text :short_text # For experts (ie non-survey takers). Short version of text
      t.text :help_text
      
      # Display
      t.string :pick
      t.string :display_type
      t.integer :display_order
      t.integer :question_group_id
      t.boolean :is_mandatory

      # Reference
      t.string :reference_identifier # For questions imported from a paper questionnaire 
      t.string :data_export_identifier # For data export. Usually a short/cryptic version of text
      
      # styling
      t.integer :display_width # used only for slider component (if needed)
      
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
