# encoding: UTF-8
# frozen_string_literal: true

class AddVersionToSurveys < ActiveRecord::Migration[4.2]
  def self.up
    add_column :surveys, :survey_version, :integer, default: 0
  end

  def self.down
    remove_column :surveys, :survey_version
  end
end
