require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer, "when creating a new answer" do
  before(:each) do
    @answer = Factory(:answer, :text => "Red")
  end
  
  it "should be valid" do
    @answer.should be_valid
  end
  
  # this causes issues with building and saving answers to questions within a grid.
  # it "should be invalid without a question_id" do
  #   @answer.question_id = nil
  #   @answer.should_not be_valid
  # end
  
  it "should have 'default' renderer with nil question.pick and response_class" do      
    @answer.question = Factory(:question, :pick => nil)
    @answer.response_class = nil
    @answer.renderer.should == :default
  end
  
  it "should have a_b renderer for a question.pick and B response_class" do
    @answer.question = Factory(:question, :pick => "a")
    @answer.response_class = "B"
    @answer.renderer.should == :a_b
  end
    
end