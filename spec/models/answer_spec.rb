require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# describe Answer, "validations" do
#   test_helper :validations
#   before(:each) do
#     @model = @answer = Answer.new(:question_id => 1, :text => "Red")
#   end
#   it 'should validate presence of' do
#     assert_invalid :text, "can't be blank", '', ' ', nil
#   end
#   it 'should validate numericality of' do
#     assert_invalid :question_id, 'is not a number', '', ' ', nil
#     assert_valid :question_id, '1', '2'
#     assert_invalid :question_id, 'is not a number', 'abcd', '1,2', '1.3'
#   end
# end
describe Answer, "when creating a new answer" do
  before(:each) do
    @q = mock_model(Question)
    @answer = Answer.new(:question => @q, :text => "Red")
  end
  
  it "should be valid" do
    @answer.should be_valid
  end

  it "should be invalid without a unique reference identifier (within the scope of its parent)" do
    pending
  end
  
  it "should return its parent question" do
    @answer.question_id.should == @q.id
    @answer.question.should == @q
  end
  
  it "should have 'default' partial_name with nil question" do
    @answer.question = nil
    @answer.partial_name.should == "default"
  end
  
  it "should have 'default' partial_name with nil question.pick and response_class" do    
    @question=mock_model(Question, :pick => nil)
    @answer.stub!(:question).and_return(@question)
    @answer.response_class = nil
    @answer.partial_name.should == "default"
  end
  
  it "should have a_b partial_name for a question.pick and b response_class_string" do
    @question=mock_model(Question, :pick => "a")
    @answer.stub!(:question).and_return(@question)
    @answer.stub!(:response_class_string).and_return("b")
    @answer.partial_name.should == "a_b"
  end
    
  it "should return a downcase response_class_string or nil" do
    @answer.response_class = nil
    @answer.response_class_string.should == nil
    @answer.response_class = "CamelCase"
    @answer.response_class_string.should == "camelcase"
  end

end