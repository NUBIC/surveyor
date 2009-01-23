require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AnswersController do

  describe "REST actions"do
    
    it "GETs all answers" do
      @answers = [mock(Answer)]
      Answer.should_receive(:find).and_return(@answers)
      get "index"
      assigns[:answers].should_not be_empty
      assigns[:answers].should == @answers
      response.should be_success
    end
    
    it "GETs one answer" do
      @answer = mock(Answer)
      Answer.should_receive(:find).and_return(@answer)
      get 'show', :id => @answer
      assigns[:answer].should == @answer
      response.should be_success
    end
    
    it "GETs a new answer" do
      get 'new'
      assigns[:answer].should_not be_nil
      response.should be_success
    end
  
    it "POSTs a new answer" do
      @answer = Answer.new()
      @answer.stub!(:new).and_return(true)
      Answer.should_receive(:new).with(@answer.attributes).and_return(@answer)
      post 'create', {:answer => @answer.attributes}
      
    end
    
    it "GETs an editable answer" do
      @answer = mock(Answer)
      Answer.should_receive(:find).and_return(@answer)
      
      get 'edit', :id  => @answer
      assigns[:answer].should == @answer
      response.should be_success
    end
    
    it "PUTs an editiable answer" do
      @answer = mock(Answer, :title => "test")
      Answer.should_receive(:find).and_return(@answer)
      @answer.stub!(:update_attributes)
      put 'update', :id => @answer
      response.should be_success
    end
    
    it "DELETEs an existing answer" do
      @answer = mock(Answer)
      @answer.stub!(:destroy)
      Answer.should_receive(:find).with(@answer).and_return(@answer)
      delete 'destroy', :id => @answer
    
    end
    
  end
end
