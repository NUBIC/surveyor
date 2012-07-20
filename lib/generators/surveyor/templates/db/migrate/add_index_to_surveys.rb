# encoding: UTF-8
class AddIndexToSurveys < ActiveRecord::Migration
  def self.up
    add_index(:surveys, :access_code, :name => 'surveys_ac_idx')
  end

  def self.down
    remove_index(:surveys, :name => 'surveys_ac_idx')
  end
end