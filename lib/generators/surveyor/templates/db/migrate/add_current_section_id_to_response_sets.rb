# encoding: UTF-8
# frozen_string_literal: true

class AddCurrentSectionIdToResponseSets < ActiveRecord::Migration[4.2]
  def self.up
    add_column :response_sets, :current_section_id, :integer
  end

  def self.down
    remove_column :response_sets, :current_section_id
  end
end
