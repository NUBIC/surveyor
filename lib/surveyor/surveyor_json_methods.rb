require 'rabl'
Rabl.register!

module Surveyor
  module SurveyorJsonMethods
    extend ActiveSupport::Concern

    def take
      all_surveys = Survey.where(:access_code => params[:survey_access_code]).order("survey_version DESC")
      survey = if params[:survey_version].blank?
        all_surveys.first
      else
        all_surveys.where(:survey_version => params[:survey_version]).first
      end
      response_set = ResponseSet.create(:survey => survey) #, :user_id => (@current_user.nil? ? @current_user : @current_user.id))
      sections = SurveySection.where(survey_id: response_set.survey_id).includes([:survey, {questions: [{answers: :question}, {question_group: :dependency}, :dependency]}])
      section = (section_id_from(params) ? sections.where(id: section_id_from(params)).first : sections.first) || sections.first
      survey = section.survey
      render json: {
        survey: survey
      }, status: :ok
    end

    def submit
      render json: {
        message: 'Survey submitted!'
      }, status: :ok
    end
  end
end