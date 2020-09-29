# encoding: UTF-8
# frozen_string_literal: true

class AddApiIdsToResponseSetsAndResponses < ActiveRecord::Migration[4.2]
  def self.up
    add_column :response_sets, :api_id, :string
    add_column :responses, :api_id, :string
  end

  def self.down
    remove_column :response_sets, :api_id
    remove_column :responses, :api_id
  end
end
