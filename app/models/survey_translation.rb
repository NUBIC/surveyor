class SurveyTranslation < ActiveRecord::Base
  unloadable
  include Surveyor::Models::SurveyTranslationMethods
end

