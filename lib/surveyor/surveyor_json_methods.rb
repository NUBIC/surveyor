require 'rabl'
Rabl.register!

module Surveyor
  module SurveyorJsonMethods
    extend ActiveSupport::Concern

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

      p "submit.params", params.to_json

      ResponseSet.transaction do
        response_set = ResponseSet.includes({:responses => :answer}).where(:access_code => params[:response_access_code]).first
        if response_set
          # response_set.update_from_ui_hash(params[:r])

          params[:r].each do |key, val|
            response_hash = val.except :api_id, :id
            response = Response.new
            p "response_hash", response_hash
            p "response", response
          end

          # create new responses from params[:r]:
          # "{
          #   \"1\": {
          #     \"question_id\": \"1\",
          #     \"api_id\": \"5eceee3c-bc73-4f6b-9bf1-3bbebc4addf0\",
          #     \"answer_id\": \"2\"
          #   },
          #   \"2\": {
          #     \"question_id\": \"2\",
          #     \"api_id\": \"6bf1dc2d-49eb-46d2-9a38-65dd533ea486\",
          #     \"answer_id\": \"6\"
          #   }
          # }"

          response_set.complete!
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