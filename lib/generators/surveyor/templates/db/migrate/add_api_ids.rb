# encoding: UTF-8
class AddApiIds < ActiveRecord::Migration
  def self.up
    add_column :surveys, :api_id, :string
    add_column :questions, :api_id, :string
    add_column :answers, :api_id, :string
  end

  def self.down
    remove_column :surveys, :api_id
    remove_column :questions, :api_id
    remove_column :answers, :api_id
  end
end
