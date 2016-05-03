require 'rabl'
Rabl.register!

module Surveyor
  module SurveyorJsonMethods
    extend ActiveSupport::Concern

    def survey_as_json
      all_surveys = Survey.where(access_code: params[:survey_access_code]).order('survey_version DESC')

      # must be @var for rabl (see survey_as_json.json.rabl)
      @survey = if params[:survey_version].blank?
        all_surveys.first
      else
        all_surveys.where(:survey_version => params[:survey_version]).first
      end

      respond_to do |format|
        format.json
      end
    end

  end
end