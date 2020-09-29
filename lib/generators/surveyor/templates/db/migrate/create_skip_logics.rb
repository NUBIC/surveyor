# encoding: UTF-8
# frozen_string_literal: true

class CreateSkipLogics < ActiveRecord::Migration[4.2]
  def self.up
    create_table :skip_logics do |t|
      # Context
      t.integer :survey_section_id
      t.integer :target_survey_section_id

      # Content
      t.string :rule
      t.integer :execute_order

      t.timestamps
    end
  end

  def self.down
    drop_table :skip_logics
  end
end
