# encoding: UTF-8
class AddQualifyLogicToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :qualify_logic, :string
  end

  def self.down
    remove_column :answers, :qualify_logic
  end
end
