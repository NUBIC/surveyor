# encoding: UTF-8
# frozen_string_literal: true

class AddUniqueIndicies < ActiveRecord::Migration[4.2]
  def self.up
    remove_index(:response_sets, name: 'response_sets_ac_idx')
    add_index(:response_sets, :access_code, name: 'response_sets_ac_idx', unique: true)

    remove_index(:surveys, name: 'surveys_ac_idx')
    add_index(:surveys, :access_code, name: 'surveys_ac_idx', unique: true)
  end

  def self.down
    remove_index(:response_sets, name: 'response_sets_ac_idx')
    add_index(:response_sets, :access_code, name: 'response_sets_ac_idx')

    remove_index(:surveys, name: 'surveys_ac_idx')
    add_index(:surveys, :access_code, name: 'surveys_ac_idx')
  end
end
