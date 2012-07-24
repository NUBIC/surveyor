# encoding: UTF-8
class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      # Context
      t.integer :survey_section_id
      t.integer :question_group_id

      # Content
      t.text :text
      t.text :short_text # For experts (ie non-survey takers). Short version of text
      t.text :help_text
      t.string :pick

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab

      # Display
      t.integer :display_order
      t.string :display_type
      t.boolean :is_mandatory
      t.integer :display_width # used only for slider component (if needed)

      t.string :custom_class
      t.string :custom_renderer

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
