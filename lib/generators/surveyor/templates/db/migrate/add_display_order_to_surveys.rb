# encoding: UTF-8
# frozen_string_literal: true

class AddDisplayOrderToSurveys < ActiveRecord::Migration[4.2]
  def self.up
    add_column :surveys, :display_order, :integer
  end

  def self.down
    remove_column :surveys, :display_order
  end
end
