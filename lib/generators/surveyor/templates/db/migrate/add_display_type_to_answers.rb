# encoding: UTF-8
# frozen_string_literal: true

class AddDisplayTypeToAnswers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :answers, :display_type, :string

    Answer.all.each do |a|
      a.update_attributes(display_type: 'hidden_label') if a.hide_label == true
    end

    remove_column :answers, :hide_label
  end

  def self.down
    add_column :answers, :hide_label, :boolean

    Answer.all.each do |a|
      a.update_attributes(hide_label: true) if a.display_type == 'hidden_label'
    end

    remove_column :answers, :display_type
  end
end
