class ReplaceVersionWithSurveyVersion < ActiveRecord::Migration
  def self.up
    remove_index( :surveys, :name => 'surveys_access_code_version_idx' )
    rename_column :surveys, :version, :survey_version
    add_index(:surveys, [ :access_code, :survey_version], :name => 'surveys_access_code_version_idx', :unique => true)
  end

  def self.down
    remove_index( :surveys, :name => 'surveys_access_code_version_idx' )
    rename_column :surveys, :survey_version, :version
    add_index(:surveys, [ :access_code, :version], :name => 'surveys_access_code_version_idx', :unique => true)
  end
end
