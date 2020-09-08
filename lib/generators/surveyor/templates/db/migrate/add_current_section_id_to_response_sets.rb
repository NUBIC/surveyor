# encoding: UTF-8
class AddCurrentSectionIdToResponseSets < ActiveRecord::Migration[4.2]
  def self.up
    add_column :response_sets, :current_section_id, :integer
  end

  def self.down
    remove_column :response_sets, :current_section_id
  end
end
