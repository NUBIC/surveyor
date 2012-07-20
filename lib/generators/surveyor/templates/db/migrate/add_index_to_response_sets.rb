# encoding: UTF-8
class AddIndexToResponseSets < ActiveRecord::Migration
  def self.up
    add_index(:response_sets, :access_code, :name => 'response_sets_ac_idx')
  end

  def self.down
    remove_index(:response_sets, :name => 'response_sets_ac_idx')
  end
end