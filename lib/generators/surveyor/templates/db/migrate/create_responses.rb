# encoding: UTF-8
class CreateResponses < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      # Context
      t.integer :response_set_id
      t.integer :question_id

      # Content
      t.integer :answer_id
      t.datetime :datetime_value # handles date, time, and datetime (segregate by answer.response_class)

      #t.datetime :time_value
      t.integer :integer_value
      t.float :float_value
      t.string :unit
      t.text :text_value
      t.string :string_value
      t.string :response_other #used to hold the string entered with "Other" type answers in multiple choice questions

      # arbitrary identifier used to group responses
      # the pertinent example here is Q: What's your car's make/model/year
      # group 1: Ford/Focus/2007
      # group 2: Toyota/Prius/2006
      t.string :response_group

      t.timestamps
    end
  end

  def self.down
    drop_table :responses
  end
end
