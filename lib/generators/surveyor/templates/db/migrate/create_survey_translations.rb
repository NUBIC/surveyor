# encoding: UTF-8
# frozen_string_literal: true

class CreateSurveyTranslations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :survey_translations do |t|
      # Content
      t.integer :survey_id

      # Reference
      t.string :locale
      t.text :translation

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_translations
  end
end
