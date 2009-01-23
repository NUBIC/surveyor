require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SectionsController do

  describe "REST actions"do
    
    it "GETs all sections" do
      @sections = [mock(SurveySection)]
      SurveySection.should_receive(:find).and_return(@sections)
      get "index"
      assigns[:sections].should_not be_empty
      assigns[:sections].should == @sections
      response.should be_success
    end
    
    it "GETs one section" do
      @section = mock(SurveySection)
      SurveySection.should_receive(:find).and_return(@section)
      get 'show', :id => @section
      assigns[:section].should == @section
      response.should be_success
    end
    
    it "GETs a new section" do
      get 'new'
      assigns[:section].should_not be_nil
      response.should be_success
    end
  
    it "POSTs a new section" do
      @section = SurveySection.new(:title => "test")
      @section.stub!(:new).and_return(true)
      SurveySection.should_receive(:new).with(@section.attributes).and_return(@section)
      post 'create', {:section => @section.attributes}
      
    end
    
    it "GETs an editable section" do
      @section = mock(SurveySection)
      SurveySection.should_receive(:find).and_return(@section)
      
      get 'edit', :id  => @section
      assigns[:section].should == @section
      response.should be_success
    end
    
    it "PUTs an editiable section" do
      @section = mock(SurveySection, :title => "test")
      SurveySection.should_receive(:find).and_return(@section)
      @section.stub!(:update_attributes)
      put 'update', :id => @section
      response.should be_success
    end
    
    it "DELETEs an existing section" do
      @section = mock(SurveySection)
      @section.stub!(:destroy)
      SurveySection.should_receive(:find).with(@section).and_return(@section)
      delete 'destroy', :id => @section
    
    end
    
  end
end
