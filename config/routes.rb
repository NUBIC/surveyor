Surveyor::Engine.routes.draw do

  root 'surveyor#index', as: :available_surveys

  # these routes are for viewing unanswered surveys
  get  '/:survey_access_code.json' => 'surveyor#survey_as_json', :defaults => { :format => 'json' }
  get  '/:survey_access_code' => 'surveyor#survey_as_view', as: :view_survey

  # these routes are for answered surveys
  get  '/:survey_access_code/:response_access_code' => 'surveyor#show', as: :view_my_survey
  put  '/:survey_access_code/:response_access_code' => 'surveyor#update', as: :update_my_survey

end