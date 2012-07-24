# encoding: UTF-8
class AddDisplayOrderToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :display_order, :integer
  end

  def self.down
    remove_column :surveys, :display_order
  end
end
