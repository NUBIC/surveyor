# encoding: UTF-8
# frozen_string_literal: true

class IncrementSurveyVersionsByOne < ActiveRecord::Migration[5.0]
  def self.up
    remove_index(:surveys, name: 'surveys_access_code_version_idx')

    execute <<-SQL
      UPDATE surveys
      SET survey_version = survey_version + 1
    SQL

    add_index(
      :surveys,
      [:access_code, :survey_version],
      name: 'surveys_access_code_version_idx',
      unique: true,
    )
  end

  def self.down
    remove_index(:surveys, name: 'surveys_access_code_version_idx')

    execute <<-SQL
      UPDATE surveys
      SET survey_version = survey_version - 1
    SQL

    add_index(
      :surveys,
      [:access_code, :survey_version],
      name: 'surveys_access_code_version_idx',
      unique: true,
    )
  end
end
