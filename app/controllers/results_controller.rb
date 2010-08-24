class ResultsController < ApplicationController
  layout 'results' 
  def index
    @surveys = Survey.all
  end

  def show
    @survey = Survey.find(params[:id])
    @response_sets = @survey.response_sets
    @questions = SurveySection.find_by_survey_id(params[:id]).questions
  end
end