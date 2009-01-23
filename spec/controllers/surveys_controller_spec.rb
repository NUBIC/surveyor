require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveysController do

  describe "REST actions"do
    
    it "GETs all surveys" do
      @surveys = [mock(Survey)]
      Survey.should_receive(:find).and_return(@surveys)
      get "index"
      assigns[:surveys].should_not be_empty
      assigns[:surveys].should == @surveys
      response.should be_success
    end
    
    it "GETs one survey" do
      @survey = mock(Survey)
      Survey.should_receive(:find).and_return(@survey)
      get 'show', :id => @survey
      assigns[:survey].should == @survey
      response.should be_success
    end
    
    it "GETs a new survey" do
      get 'new'
      assigns[:survey].should_not be_nil
      response.should be_success
    end
  
    it "POSTs a new survey" do
      @survey = Survey.new(:title => "test")
      @survey.stub!(:new).and_return(true)
      Survey.should_receive(:new).with(@survey.attributes).and_return(@survey)
      post 'create', {:survey => @survey.attributes}
      
    end
    
    it "GETs an editable survey" do
      @survey = mock(Survey)
      Survey.should_receive(:find).and_return(@survey)
      
      get 'edit', :id  => @survey
      assigns[:survey].should == @survey
      response.should be_success
    end
    
    it "PUTs an editiable survey" do
      @survey = mock(Survey, :title => "test")
      Survey.should_receive(:find).and_return(@survey)
      @survey.stub!(:update_attributes)
      put 'update', :id => @survey
      response.should be_success
    end
    
    it "DELETEs an existing survey" do
      @survey = mock(Survey)
      @survey.stub!(:destroy)
      Survey.should_receive(:find).with(@survey).and_return(@survey)
      delete 'destroy', :id => @survey
    
    end
    
  end
end
