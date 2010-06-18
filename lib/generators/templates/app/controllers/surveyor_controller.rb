module SurveyorControllerCustomMethods
  def self.included(base)
    # base.send :before_filter, :require_user   # AuthLogic
    # base.end :before_filter, :login_required  # Restful Authentication
  end

  # Actions
  def new
    super
  end
  def create
    super
  end
  def show
    super
  end
  def edit
    super
  end
  def update
    super
  end
end
class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  include SurveyorControllerCustomMethods
end
