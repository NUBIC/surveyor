require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionsController do

  describe "REST actions"do
    
    it "GETs all questions" do
      @questions = [mock(Question)]
      Question.should_receive(:find).and_return(@questions)
      get "index"
      assigns[:questions].should_not be_empty
      assigns[:questions].should == @questions
      response.should be_success
    end
    
    it "GETs one question" do
      @question = mock(Question)
      Question.should_receive(:find).and_return(@question)
      get 'show', :id => @question
      assigns[:question].should == @question
      response.should be_success
    end
    
    it "GETs a new question" do
      get 'new'
      assigns[:question].should_not be_nil
      response.should be_success
    end
  
    it "POSTs a new question" do
      @question = Question.new()
      @question.stub!(:new).and_return(true)
      Question.should_receive(:new).with(@question.attributes).and_return(@question)
      post 'create', {:question => @question.attributes}
      
    end
    
    it "GETs an editable question" do
      @question = mock(Question)
      Question.should_receive(:find).and_return(@question)
      
      get 'edit', :id  => @question
      assigns[:question].should == @question
      response.should be_success
    end
    
    it "PUTs an editiable question" do
      @question = mock(Question, :title => "test")
      Question.should_receive(:find).and_return(@question)
      @question.stub!(:update_attributes)
      put 'update', :id => @question
      response.should be_success
    end
    
    it "DELETEs an existing question" do
      @question = mock(Question)
      @question.stub!(:destroy)
      Question.should_receive(:find).with(@question).and_return(@question)
      delete 'destroy', :id => @question
    
    end
    
  end
end
