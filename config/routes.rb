ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'surveying' do |surveying|
      surveying.available_surveys '/',                                      :conditions => {:method => :get}, :action => "new"      # GET survey list
      surveying.take_survey       ':survey_code',                           :conditions => {:method => :post}, :action => "create"  # Only POST of survey to cre
      surveying.view_my_survey    ':survey_code/:response_set_code',        :conditions => {:method => :get}, :action => "show"     # GET viewable/printable? su
      surveying.edit_my_survey    ':survey_code/:response_set_code/take',   :conditions => {:method => :get}, :action => "edit"     # GET editable survey 
      surveying.update_my_survey  ':survey_code/:response_set_code',        :conditions => {:method => :put}, :action => "update"   # PUT edited survey 
      surveying.finish_my_survey  ':survey_code/:response_set_code/finish', :conditions => {:method => :put}, :action => "finish"   # PUT to close out the respo
  end 

  map.resources :surveys
  map.resources :sections
  map.resources :questions
  map.resources :answers
  map.resources :dependencies
  map.resources :dependency_conditions
  map.resources :response_sets
end


