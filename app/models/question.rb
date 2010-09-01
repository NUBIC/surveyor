class Question < ActiveRecord::Base
  unloadable
  include Surveyor::Models::QuestionMethods
end