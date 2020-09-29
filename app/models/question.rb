# frozen_string_literal: true

class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods
end
