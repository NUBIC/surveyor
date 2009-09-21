class CreateQuestionGroups < ActiveRecord::Migration
  def self.up
    create_table :question_groups do |t|
      # Content
      t.string :text
      t.string :help_text
      
      # Display
      t.string :display_type

      t.timestamps
    end
  end

  def self.down
    drop_table :question_groups
  end
end
