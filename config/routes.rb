ActionController::Routing::Routes.draw do |map|
  root = Surveyor::Config['default.relative_url_root'] || "surveys"
  root = (root << "/").gsub(/\/+/, "/")
  map.with_options :controller => 'surveyor' do |s|
    s.available_surveys "#{root}",                                       :conditions => {:method => :get}, :action => "new"      # GET survey list
    s.take_survey       "#{root}:survey_code",                           :conditions => {:method => :post}, :action => "create"  # Only POST of survey to create
    s.view_my_survey    "#{root}:survey_code/:response_set_code",        :conditions => {:method => :get}, :action => "show"     # GET viewable/printable? survey
    s.edit_my_survey    "#{root}:survey_code/:response_set_code/take",   :conditions => {:method => :get}, :action => "edit"     # GET editable survey 
    s.update_my_survey  "#{root}:survey_code/:response_set_code",        :conditions => {:method => :put}, :action => "update"   # PUT edited survey 
  end   
end