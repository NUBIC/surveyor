ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'surveying' do |s|
    s.available_surveys 'surveys/',                                       :conditions => {:method => :get}, :action => "new"      # GET survey list
    s.take_survey       'surveys/:survey_code',                           :conditions => {:method => :post}, :action => "create"  # Only POST of survey to cre
    s.view_my_survey    'surveys/:survey_code/:response_set_code',        :conditions => {:method => :get}, :action => "show"     # GET viewable/printable? su
    s.edit_my_survey    'surveys/:survey_code/:response_set_code/take',   :conditions => {:method => :get}, :action => "edit"     # GET editable survey 
    s.update_my_survey  'surveys/:survey_code/:response_set_code',        :conditions => {:method => :put}, :action => "update"   # PUT edited survey 
  end 
end