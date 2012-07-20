# encoding: UTF-8
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
      t.string :response_class # What kind of additional data does this answer accept?

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab

      # Display
      t.integer :display_order
      t.boolean :is_exclusive # If set it causes some UI trigger to remove (and disable) all the other answer choices selected for a question (needed for the WHR)
      t.boolean :hide_label
      t.integer :display_length # if smaller than answer.length the html input length will be this value

      t.string :custom_class
      t.string :custom_renderer

      t.timestamps

    end
  end

  def self.down
    drop_table :answers
  end
end
