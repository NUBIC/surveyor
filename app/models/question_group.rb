class QuestionGroup < ActiveRecord::Base
  unloadable
  include Surveyor::Models::QuestionGroupMethods
  
end
