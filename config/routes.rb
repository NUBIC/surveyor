Rails.application.routes.draw do
  match 'results', :to                                      => 'results#index', :as   => 'results', :via           => :get
  match 'results/:survey_code', :to                         => 'results#show', :as    => 'result', :via            => :get
  match 'surveys', :to                                      => 'surveyor#new', :as    => 'available_surveys', :via => :get
  match 'surveys/:survey_code', :to                         => 'surveyor#create', :as => 'take_survey', :via       => :post
  match 'surveys/:survey_code/:response_set_code', :to      => 'surveyor#show', :as   => 'view_my_survey', :via    => :get
  match 'surveys/:survey_code/:response_set_code/take', :to => 'surveyor#edit', :as   => 'edit_my_survey', :via    => :get
  match 'surveys/:survey_code/:response_set_code', :to      => 'surveyor#update', :as => 'update_my_survey', :via  => :put
end                                                                                      