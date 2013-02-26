# encoding: UTF-8
class AddInputMaskAttributesToAnswer < ActiveRecord::Migration
  def change
  	add_column :answers, :input_mask, :string
  	add_column :answers, :placeholder, :string, :limit => 1
  end
end
