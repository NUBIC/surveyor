# encoding: UTF-8
# frozen_string_literal: true

class AddApiIdToQuestionGroups < ActiveRecord::Migration[4.2]
  def self.up
    add_column :question_groups, :api_id, :string
  end

  def self.down
    remove_column :question_groups, :api_id
  end
end
