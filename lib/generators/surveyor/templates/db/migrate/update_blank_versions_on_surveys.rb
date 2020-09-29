# encoding: UTF-8
# frozen_string_literal: true

class Survey < ActiveRecord::Base; end
class UpdateBlankVersionsOnSurveys < ActiveRecord::Migration[4.2]
  def self.up
    Survey.where('survey_version IS ?', nil).each do |s|
      s.survey_version = 0
      s.save!
    end
  end

  def self.down; end
end
