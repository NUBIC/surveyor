# encoding: UTF-8
# frozen_string_literal: true

class AddSectionIdToResponses < ActiveRecord::Migration[4.2]
  def self.up
    add_column :responses, :survey_section_id, :integer
    add_index :responses, :survey_section_id
  end

  def self.down
    remove_index :responses, :survey_section_id
    remove_column :responses, :survey_section_id
  end
end
