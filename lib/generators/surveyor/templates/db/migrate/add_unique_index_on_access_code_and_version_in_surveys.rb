# encoding: UTF-8
# frozen_string_literal: true

class AddUniqueIndexOnAccessCodeAndVersionInSurveys < ActiveRecord::Migration[4.2]
  def self.up
    add_index(
      :surveys,
      [:access_code, :survey_version],
      name: 'surveys_access_code_version_idx',
      unique: true,
    )
  end

  def self.down
    remove_index(:surveys, name: 'surveys_access_code_version_idx')
  end
end
