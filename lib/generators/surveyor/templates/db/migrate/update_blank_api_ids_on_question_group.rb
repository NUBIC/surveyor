require 'uuidtools'

class QG < ActiveRecord::Base
  set_table_name 'question_groups' 
end

class UpdateBlankApiIdsOnQuestionGroup < ActiveRecord::Migration
  def self.up
    QG.where('api_id IS ?', nil).each do |qg|
      qg.api_id = UUIDTools::UUID.random_create.to_s
      qg.save!
    end
  end

  def self.down
  end
end
