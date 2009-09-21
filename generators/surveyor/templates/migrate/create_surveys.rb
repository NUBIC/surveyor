class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      # Content
      t.string :title
      t.text :description

      # Reference
      t.string :access_code

      # Expiry
      t.datetime :active_at
      t.datetime :inactive_at
      
      # Styling
      t.string :css_url
            
      t.timestamps
    end
  end

  def self.down
    drop_table :surveys
  end
end
