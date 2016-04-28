require 'rabl'
Rabl.register!

module Surveyor
  module SurveyorJsonMethods
    extend ActiveSupport::Concern
    skip_before_filter :verify_authenticity_token

    def survey
      # see questions.json.rabl
      all_surveys = Survey.where(:access_code => params[:survey_access_code]).order("survey_version DESC")
      survey = if params[:survey_version].blank?
        all_surveys.first
      else
        all_surveys.where(:survey_version => params[:survey_version]).first
      end
      params[:employee_id] ||= nil
      @response_set = ResponseSet.create(:survey => survey, :user_id => params[:employee_id])
      respond_to do |format|
        format.json
      end
    end

    def submit
      render json: {
        message: 'Missing "r" key.'
      }, status: :bad_request unless params[:r].present?

      ResponseSet.transaction do
        response_set = ResponseSet.includes({:responses => :answer}).where(:access_code => params[:response_access_code]).first
        if response_set
          response_set.update_from_ui_hash(params[:r])
          render json: {
            message: 'Survey submitted!'
          }, status: :ok
        else
          render json: {
            message: 'ResponseSet not found.'
          }, status: :not_found
          false
        end
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