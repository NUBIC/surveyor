require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DependenciesController do

  describe "REST actions"do
    
    it "GETs all dependencies" do
      @dependencies = [mock(Dependency)]
      Dependency.should_receive(:find).and_return(@dependencies)
      get "index"
      assigns[:dependencies].should_not be_empty
      assigns[:dependencies].should == @dependencies
      response.should be_success
    end
    
    it "GETs one survey" do
      @dependency = mock(Survey)
      Dependency.should_receive(:find).and_return(@dependency)
      get 'show', :id => @dependency
      assigns[:dependency].should == @dependency
      response.should be_success
    end
    
    it "GETs a new survey" do
      get 'new'
      assigns[:dependency].should_not be_nil
      response.should be_success
    end
  
    it "POSTs a new survey" do
      @dependency = Dependency.new()
      @dependency.stub!(:new).and_return(true)
      Dependency.should_receive(:new).with(@dependency.attributes).and_return(@dependency)
      post 'create', {:dependency => @dependency.attributes}
      
    end
    
    it "GETs an editable survey" do
      @dependency = mock(Dependency)
      Dependency.should_receive(:find).and_return(@dependency)
      
      get 'edit', :id  => @dependency
      assigns[:dependency].should == @dependency
      response.should be_success
    end
    
    it "PUTs an editiable survey" do
      @dependency = mock(Dependency, :title => "test")
      Dependency.should_receive(:find).and_return(@dependency)
      @dependency.stub!(:update_attributes)
      put 'update', :id => @dependency
      response.should be_success
    end
    
    it "DELETEs an existing survey" do
      @dependency = mock(Dependency)
      @dependency.stub!(:destroy)
      Dependency.should_receive(:find).with(@dependency).and_return(@dependency)
      delete 'destroy', :id => @dependency
    
    end
  end
end
