# frozen_string_literal: true

class Survey < ActiveRecord::Base
  include Surveyor::Models::SurveyMethods
end
