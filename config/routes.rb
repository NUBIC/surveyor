ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'results' do |r|
    r.results "results", :conditions => {:method => :get}, :action => "index"
    r.result "results/:survey_code", :conditions => {:method => :get}, :action => "show"
  end   
  map.with_options :controller => 'surveyor' do |s|
    s.available_surveys "surveys",                                        :conditions => {:method => :get}, :action => "new"                      # GET survey list
    s.take_survey       "surveys/:survey_code",                            :conditions => {:method => :post}, :action => "create"                  # Only POST of survey to create
    s.view_my_survey    "surveys/:survey_code/:response_set_code.:format", :conditions => {:method => :get}, :action => "show", :format => "html"  # GET viewable/printable? survey
    s.edit_my_survey    "surveys/:survey_code/:response_set_code/take",    :conditions => {:method => :get}, :action => "edit"                     # GET editable survey 
    s.update_my_survey  "surveys/:survey_code/:response_set_code",         :conditions => {:method => :put}, :action => "update"                   # PUT edited survey 
  end
end
