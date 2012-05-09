class AddUniqueIndexOnAccessCodeAndVersionInSurveys < ActiveRecord::Migration
  def self.up
    add_index(:surveys, [ :access_code, :version], :name => 'surveys_access_code_version_idx', :unique => true)
  end

  def self.down
    remove_index( :surveys, :name => 'surveys_access_code_version_idx' )
  end
end
