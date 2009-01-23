require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DependencyConditionsController do

  describe "REST actions"do
    
    it "GETs all dependency_conditions" do
      @dependency_conditions = [mock(DependencyCondition)]
      DependencyCondition.should_receive(:find).and_return(@dependency_conditions)
      get "index"
      assigns[:dependency_conditions].should_not be_empty
      assigns[:dependency_conditions].should == @dependency_conditions
      response.should be_success
    end
    
    it "GETs one dependency_condition" do
      @dependency_condition = mock(DependencyCondition)
      DependencyCondition.should_receive(:find).and_return(@dependency_condition)
      get 'show', :id => @dependency_condition
      assigns[:dependency_condition].should == @dependency_condition
      response.should be_success
    end
    
    it "GETs a new dependency_condition" do
      get 'new'
      assigns[:dependency_condition].should_not be_nil
      response.should be_success
    end
  
    it "POSTs a new dependency_condition" do
      @dependency_condition = DependencyCondition.new()
      @dependency_condition.stub!(:new).and_return(true)
      DependencyCondition.should_receive(:new).with(@dependency_condition.attributes).and_return(@dependency_condition)
      post 'create', {:dependency_condition => @dependency_condition.attributes}
      
    end
    
    it "GETs an editable dependency_condition" do
      @dependency_condition = mock(DependencyCondition)
      DependencyCondition.should_receive(:find).and_return(@dependency_condition)
      
      get 'edit', :id  => @dependency_condition
      assigns[:dependency_condition].should == @dependency_condition
      response.should be_success
    end
    
    it "PUTs an editiable dependency_condition" do
      @dependency_condition = mock(DependencyCondition, :title => "test")
      DependencyCondition.should_receive(:find).and_return(@dependency_condition)
      @dependency_condition.stub!(:update_attributes)
      put 'update', :id => @dependency_condition
      response.should be_success
    end
    
    it "DELETEs an existing dependency_condition" do
      @dependency_condition = mock(DependencyCondition)
      @dependency_condition.stub!(:destroy)
      DependencyCondition.should_receive(:find).with(@dependency_condition).and_return(@dependency_condition)
      delete 'destroy', :id => @dependency_condition
    
    end
    
  end
end
