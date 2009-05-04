require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveyingController do
  describe "route generation" do
    it "should map { :controller => 'surveying', :action => 'new'} to /" do
      route_for(:controller => 'surveying', :action => "new").should == "/"
    end  
    it "should map { :controller => 'surveying', :action => 'create', :survey_code => 1} to /1" do
      route_for(:controller => 'surveying', :action => "create", :survey_code => 1).should == "/1"
    end
    it "should map { 'surveying', :action => 'show', :survey_code => 1, :response_set_code => 'XYZ'} to /1/XYZ" do
      route_for(:controller => 'surveying', :action => "show", :survey_code => 1, :response_set_code => "XYZ").should == "/1/XYZ"
    end
    it "should map { :controller => 'surveying', :action => 'edit', :survey_code => 1, :response_set_code => 'XYZ'} to /1/XYZ/take" do
      route_for(:controller => 'surveying', :action => "edit", :survey_code => 1, :response_set_code => "XYZ").should == "/1/XYZ/take"
    end  
    it "should map { :controller => 'surveying', :action => 'update', :survey_code => 1, :response_set_code => 'XYZ'} to /1/XYZ" do
      route_for(:controller => 'surveying', :action => "update", :survey_code => 1, :response_set_code => "XYZ").should == "/1/XYZ"
    end
    it "should map { :controller => 'surveying', :action => 'finish', :survey_code => 1, :response_set_code => 'XYZ'} to /1/XYZ/finish" do
      route_for(:controller => 'surveying', :action => "finish", :survey_code => 1, :response_set_code => "XYZ").should == "/1/XYZ/finish"
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'surveying', :action => 'new' } from GET /" do
      params_from(:get, "/").should == {:controller => 'surveying', :action => "new"}
    end
    it "should generate params { :controller => 'surveying', :action => 'create', :survey_code => '1' } from POST /1" do
      params_from(:post, "/1").should == {:controller => 'surveying', :action => "create", :survey_code => "1"}
    end
    it "should generate params { :controller => 'surveying', :action => 'show', :survey_code => '1', :response_set_code => 'XYZ' } from GET /1/XYZ" do
      params_from(:get, "/1/XYZ").should == {:controller => 'surveying', :action => "show", :survey_code => "1", :response_set_code => "XYZ"}
    end
    it "should generate params { :controller => 'surveying', :action => 'edit', :survey_code => '1', :response_set_code => 'XYZ' } from GET /1/XYZ/take" do
      params_from(:get, "/1/XYZ/take").should == {:controller => 'surveying', :action => "edit", :survey_code => "1", :response_set_code => "XYZ"}
    end
    it "should generate params { :controller => 'surveying', :action => 'update', :survey_code => '1', :response_set_code } from PUT /1/XYZ" do
      params_from(:put, "/1/XYZ").should == {:controller => 'surveying', :action => "update", :survey_code => "1", :response_set_code => "XYZ"}
    end
    it "should generate params { :controller => 'surveying', :action => 'finish', :survey_code => '1', :response_set_code } from PUT /1/XYZ/finish" do
      params_from(:put, "/1/XYZ/finish").should == {:controller => 'surveying', :action => "finish", :survey_code => "1", :response_set_code => "XYZ"}
    end
  end
end
