# encoding: UTF-8
# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :answers do |t|
      # Context
      t.integer :question_id

      # Content
      t.text :text
      # Used for presenting responses to experts (ie non-survey takers).
      # Just a shorted version of the string
      t.text :short_text
      t.text :help_text

      # Used to assign a weight to an answer object (used for computing surveys that have numerical
      # results) (I added this to support the Urology questionnaire -BLC)
      t.integer :weight
      t.string :response_class # What kind of additional data does this answer accept?

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab

      # Display
      t.integer :display_order
      # If set it causes some UI trigger to remove (and disable) all the other
      # answer choices selected for a question (needed for the WHR)
      t.boolean :is_exclusive
      t.boolean :hide_label
      # if smaller than answer.length the html input length will be this value
      t.integer :display_length

      t.string :custom_class
      t.string :custom_renderer

      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
