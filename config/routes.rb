Surveyor::Engine.routes.draw do

  get  '/api/:survey_access_code' => 'surveyor#take', :defaults => { :format => 'json' }
  post '/api/:survey_access_code' => 'surveyor#submit', :defaults => { :format => 'json' }

  get  '/' => 'surveyor#index', as: :available_surveys
  get  '/:survey_access_code' => 'surveyor#sample', as: :sample_survey
  get  '/:survey_access_code/export' => 'surveyor#export', as: :export_survey
  get  '/:survey_access_code/:response_access_code' => 'surveyor#show', as: :view_my_survey
  put  '/:survey_access_code/:response_access_code' => 'surveyor#update', as: :update_my_survey


  # match '/new', :to                                  => 'surveyor#new', :as    => 'available_surveys', :via => :get
  # get '/:survey_code(.json)' => 'surveyor#take'
  # match '/:survey_code', :to                         => 'surveyor#create', :as => 'take_survey', :via       => :post
  # match '/:survey_code', :to                         => 'surveyor#export', :as => 'export_survey', :via     => :get
  # match '/:survey_code/:response_set_code', :to      => 'surveyor#show', :as   => 'view_my_survey', :via    => :get
  # match '/:survey_code/:response_set_code/take', :to => 'surveyor#edit', :as   => 'edit_my_survey', :via    => :get
  # match '/:survey_code/:response_set_code', :to      => 'surveyor#update', :as => 'update_my_survey', :via  => :put
end