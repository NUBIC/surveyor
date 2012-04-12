require 'uuid'

class QG < ActiveRecord::Base
  set_table_name 'question_groups' 
end

class UpdateBlankApiIdsOnQuestionGroup < ActiveRecord::Migration
  def self.up
    QG.where('api_id IS ?', nil).each do |qg|
      qg.api_id = UUID.generate
      qg.save!
    end
  end

  def self.down
  end
end
