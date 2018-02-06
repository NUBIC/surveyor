# encoding: UTF-8
class AddDictionaryFieldsToSurveys < ActiveRecord::Migration
  #these were added for generating datadictionies later based on survey data
  def self.up
    add_column :surveys, :acronym, :string
    add_column :surveys, :acronym_expanded, :string
    add_column :surveys, :published_reference, :string
  end

  def self.down
    remove_column :surveys, :acronym, :string
    remove_column :surveys, :acronym_expanded, :string
    remove_column :surveys, :published_reference, :string
  end
end
