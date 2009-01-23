with_options :controller => 'surveying' do |map|
    map.available_surveys '/',                                        :conditions => {:method => :get}, :action => "new"      # GET survey list
    map.take_survey       ':survey_code',                           :conditions => {:method => :post}, :action => "create"  # Only POST of survey to create
    map.view_my_survey    ':survey_code/:response_set_code',        :conditions => {:method => :get}, :action => "show"     # GET viewable/printable? survey
    map.edit_my_survey    ':survey_code/:response_set_code/take',   :conditions => {:method => :get}, :action => "edit"     # GET editable survey 
    map.update_my_survey  ':survey_code/:response_set_code',        :conditions => {:method => :put}, :action => "update"   # PUT edited survey 
    map.finish_my_survey  ':survey_code/:response_set_code/finish', :conditions => {:method => :put}, :action => "finish"   # PUT to close out the response_set
end
  
resources :surveys
resources :sections
resources :questions
resources :answers
resources :dependencies
resources :dependency_conditions
resources :response_sets