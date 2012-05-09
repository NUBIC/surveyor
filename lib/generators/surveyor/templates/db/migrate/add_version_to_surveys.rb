class AddVersionToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :version, :integer, :default => 0
  end

  def self.down
    remove_column :surveys, :version
  end
end
