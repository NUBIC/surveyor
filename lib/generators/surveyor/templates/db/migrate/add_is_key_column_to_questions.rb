class AddIsKeyColumnToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :is_key, :boolean, default: false, null: false
  end
end