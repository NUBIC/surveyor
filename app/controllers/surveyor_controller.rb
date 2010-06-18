# The Surveyor controller a user taking a survey. It is semi-RESTful since it does not have a concrete representation model.
# The "resource" is a survey attempt/session populating a response set.
class SurveyorController < ApplicationController
  unloadable
  include SurveyorControllerMethods
end

