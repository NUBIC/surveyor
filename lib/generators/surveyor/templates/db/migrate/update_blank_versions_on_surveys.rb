# encoding: UTF-8
class Survey < ActiveRecord::Base; end
class UpdateBlankVersionsOnSurveys < ActiveRecord::Migration
  def self.up
    Survey.where('survey_version IS ?', nil).each do |s|
      s.survey_version = 0
      s.save!
    end
  end

  def self.down
  end
end
