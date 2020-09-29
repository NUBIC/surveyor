# frozen_string_literal: true

class Answer < ActiveRecord::Base
  include Surveyor::Models::AnswerMethods
end
