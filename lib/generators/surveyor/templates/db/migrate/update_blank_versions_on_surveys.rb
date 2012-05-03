class Survey < ActiveRecord::Base; end
class UpdateBlankVersionsOnSurveys < ActiveRecord::Migration
  def self.up
    Survey.where('version IS ?', nil).each do |s|
      s.version = 0
      s.save!
    end
  end

  def self.down
  end
end
