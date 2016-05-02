Surveyor::Engine.routes.draw do

  get '/dashboard' => 'surveyor#index', as: :available_surveys

  get  '/:survey_access_code.json' => 'surveyor#survey', :defaults => { :format => 'json' }
  post '/:survey_access_code.json' => 'surveyor#submit', :defaults => { :format => 'json' }
  get  '/:survey_access_code/:response_access_code.json' => 'surveyor#results', :defaults => { :format => 'json' }

  get  '/:survey_access_code' => 'surveyor#sample', as: :sample_survey
  get  '/:survey_access_code/:response_access_code' => 'surveyor#show', as: :view_my_survey
  put  '/:survey_access_code/:response_access_code' => 'surveyor#update', as: :update_my_survey

end