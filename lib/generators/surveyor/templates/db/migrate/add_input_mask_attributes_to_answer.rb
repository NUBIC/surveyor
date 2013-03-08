# encoding: UTF-8
class AddInputMaskAttributesToAnswer < ActiveRecord::Migration
  def self.up
    add_column :answers, :input_mask, :string
    add_column :answers, :input_mask_placeholder, :string
  end

  def self.down
    remove_column :answers, :input_mask
    remove_column :answers, :input_mask_placeholder
  end
end
