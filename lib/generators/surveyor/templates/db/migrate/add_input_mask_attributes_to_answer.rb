# encoding: UTF-8
# frozen_string_literal: true

class AddInputMaskAttributesToAnswer < ActiveRecord::Migration[4.2]
  def self.up
    add_column :answers, :input_mask, :string
    add_column :answers, :input_mask_placeholder, :string
  end

  def self.down
    remove_column :answers, :input_mask
    remove_column :answers, :input_mask_placeholder
  end
end
