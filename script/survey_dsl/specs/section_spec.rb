require File.dirname(__FILE__) + '/../section'

describe Section, " when first created" do

  TEST_TITLE = "Demographics"
  TEST_SECTION = :B

  before do    
    @section = Section.new(1,TEST_SECTION,TEST_TITLE)
  end
  
  it "should accept questions" do
    mock_question = mock("question")
    @section.questions.size.should eql(0)
    @section.add_question(mock_question)
    @section.questions.size.should eql(1)
  end  
  
  it "should output current state to code" do
    @section.should.respond_to?(:to_code)
  end

end

describe Section, " when it contains data" do
  
  before do # Mocking up some questions
    @section = Section.new(1,TEST_SECTION,TEST_TITLE)
    mq1 = mock("question")
    mq1.stub!(:context_id).and_return("B1")
    @section.add_question(mq1)
    
    mq2 = mock("question")
    mq2.stub!(:context_id).and_return("B2")
    @section.add_question(mq2)
    
    mq3 = mock("question")
    mq3.stub!(:context_id).and_return("B3")
    @section.add_question(mq3)
    
  end
  
  it "should have added the test questions correctly" do
    @section.questions.length.should eql(3)
  end
  
  it "should have a title" do
    @section.title.should eql(TEST_TITLE)
  end
  
  it "should find a question by context_id" do
    pending # yoon: commented out during dsl refactoring
    q_to_find = @section.find_question_by_context_id("B2")
    q_to_find.should_not eql(nil)
    q_to_find.context_id.should eql("B2")
  end
  
end
