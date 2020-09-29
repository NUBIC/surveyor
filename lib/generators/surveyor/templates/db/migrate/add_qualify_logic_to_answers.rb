# encoding: UTF-8
# frozen_string_literal: true

class AddQualifyLogicToAnswers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :answers, :qualify_logic, :string
  end

  def self.down
    remove_column :answers, :qualify_logic
  end
end
