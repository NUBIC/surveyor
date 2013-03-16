Surveyor::Engine.routes.draw do
  match '/', :to                                     => 'surveyor#new', :as    => 'available_surveys', :via => :get
  match '/:survey_code', :to                         => 'surveyor#create', :as => 'take_survey', :via       => :post
  match '/:survey_code', :to                         => 'surveyor#export', :as => 'export_survey', :via     => :get
  match '/:survey_code/:response_set_code', :to      => 'surveyor#show', :as   => 'view_my_survey', :via    => :get
  match '/:survey_code/:response_set_code/take', :to => 'surveyor#edit', :as   => 'edit_my_survey', :via    => :get
  match '/:survey_code/:response_set_code', :to      => 'surveyor#update', :as => 'update_my_survey', :via  => :put
end
