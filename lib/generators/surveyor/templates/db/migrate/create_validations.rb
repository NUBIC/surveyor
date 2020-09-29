# encoding: UTF-8
# frozen_string_literal: true

class CreateValidations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :validations do |t|
      # Context
      t.integer :answer_id # the answer to validate

      # Conditional
      t.string :rule

      # Message
      t.string :message

      t.timestamps
    end
  end

  def self.down
    drop_table :validations
  end
end
