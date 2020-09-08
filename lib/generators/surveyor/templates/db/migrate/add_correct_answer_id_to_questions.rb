# encoding: UTF-8
class AddCorrectAnswerIdToQuestions < ActiveRecord::Migration[4.2]
  def self.up
    add_column :questions, :correct_answer_id, :integer
  end

  def self.down
    remove_column :questions, :correct_answer_id
  end
end
