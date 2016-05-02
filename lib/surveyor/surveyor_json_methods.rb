require 'rabl'
Rabl.register!

module Surveyor
  module SurveyorJsonMethods
    extend ActiveSupport::Concern

    def survey
      render json: {
        message: 'Missing "employee_id" key. We need to be able to associate the employee with the survey taken.'
      }, status: :bad_request unless params[:employee_id].present?

      all_surveys = Survey.where(:access_code => params[:survey_access_code]).order("survey_version DESC")
      survey = if params[:survey_version].blank?
        all_surveys.first
      else
        all_surveys.where(:survey_version => params[:survey_version]).first
      end

      params[:employee_id] ||= nil
    
      # must be @var because of rabl (see questions.json.rabl)
      @response_set = ResponseSet.create(:survey => survey, :user_id => params[:employee_id])
      respond_to do |format|
        format.json
      end
    end

    def submit
      render json: {
        message: 'Missing "r" key (Required to generate survey responses.)'
      }, status: :bad_request unless params[:r].present?

      response_set = ResponseSet.includes({:responses => :answer}).where(:access_code => params[:response_access_code]).first
      if response_set
        # iterate through each question/answer and create a Response
        params[:r].each do |key, val|
          response_hash = val.except :api_id, :id
          response = Response.new(response_set: response_set)
          response.update(response_hash)
          response.save
        end

        # this just sets the completed_at field
        response_set.complete!

        render json: {
          message: 'Survey successfully submitted.',
          data: {
            survey: response_set.survey
          }
        }, status: :ok
      else
        render json: {
          message: 'ResponseSet not found.'
        }, status: :not_found
      end
    end

    def results
      # see result_as_json.json.rabl
      @response_set = ResponseSet.find_by_access_code(params[:response_access_code])
      respond_to do |format|
        format.json
      end
    end

  end
end