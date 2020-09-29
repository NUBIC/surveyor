# encoding: UTF-8
# frozen_string_literal: true

class CreateDependencies < ActiveRecord::Migration[4.2]
  def self.up
    create_table :dependencies do |t|
      # Context
      t.integer :question_id # the dependent question
      t.integer :question_group_id

      # Conditional
      t.string :rule

      # Result - TODO: figure out the dependency hook presentation options
      # t.string :property_to_toggle # visibility, class_name,
      # t.string :effect #blind, opacity

      t.timestamps
    end
  end

  def self.down
    drop_table :dependencies
  end
end
