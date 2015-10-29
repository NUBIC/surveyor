# encoding: UTF-8
class Survey < ActiveRecord::Base; end
class Question < ActiveRecord::Base; end
class QuestionGroup < ActiveRecord::Base; end
class Answer < ActiveRecord::Base; end
class Response < ActiveRecord::Base; end
class ResponseSet < ActiveRecord::Base; end

class UpdateBlankApiIdsOnQuestionGroup < ActiveRecord::Migration
  def self.up
    check = [Survey, Question, QuestionGroup, Answer, Response, ResponseSet]
    check.each do |clazz|
      clazz.where('api_id IS ?', nil).each do |c|
        c.api_id = Surveyor::Common.generate_api_id
        c.save!
      end
    end
  end

  def self.down
  end
end
