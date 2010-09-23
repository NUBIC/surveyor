class ResultsController < ApplicationController
  helper 'surveyor'
  layout 'results' 
  def index
    @surveys = Survey.all
  end

  def show
    @survey = Survey.find_by_access_code(params[:survey_code])
    @response_sets = @survey.response_sets
    @questions = @survey.sections_with_questions.map(&:questions).flatten
  end
end