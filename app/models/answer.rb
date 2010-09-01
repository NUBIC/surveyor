class Answer < ActiveRecord::Base
  unloadable
  include Surveyor::Models::AnswerMethods
end
