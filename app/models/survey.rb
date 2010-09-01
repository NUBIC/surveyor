class Survey < ActiveRecord::Base
  unloadable
  include Surveyor::Models::SurveyMethods  
end
