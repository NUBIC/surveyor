require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe DependencyCondition, "Class methods" do
  it "should have a list of operators" do
    %w(== != < > <= >=).each{|operator| DependencyCondition.operators.include?(operator).should be_true }
  end
end

describe DependencyCondition, "instance" do
  before(:each) do
    @dependency_condition = DependencyCondition.new(:dependency_id => 1, :question_id => 45, :operator => "==", :answer_id => 23, :rule_key => "1")
  end

  it "should be valid" do
    @dependency_condition.should be_valid
  end

  it "should be invalid without a parent dependency_id, question_id, answer_id" do
    @dependency_condition.dependency_id = nil
    @dependency_condition.should have(1).errors_on(:dependency_id)
    @dependency_condition.question_id = nil
    @dependency_condition.should have(1).errors_on(:question_id)
    @dependency_condition.answer_id = nil
    @dependency_condition.should have(1).errors_on(:answer_id)
  end

  it "should be invalid without an operator" do
    @dependency_condition.operator = nil
    @dependency_condition.should have(2).errors_on(:operator)
  end
  
  it "should be invalid without a rule_key" do
    @dependency_condition.should be_valid
    @dependency_condition.rule_key = nil
    @dependency_condition.should_not be_valid
    @dependency_condition.should have(1).errors_on(:rule_key)
  end

  it "should have unique rule_key within the context of a dependency" do
   @dependency_condition.should be_valid
   DependencyCondition.create(:dependency_id => 2, :question_id => 46, :operator => "==", :answer_id => 14, :rule_key => "2")
   @dependency_condition.rule_key = "2" #rule key uniquness is scoped by dependency_id
   @dependency_condition.dependency_id = 2
   @dependency_condition.should_not be_valid
   @dependency_condition.should have(1).errors_on(:rule_key)
  end

  it "should have an operator in DependencyCondition.operators" do
    DependencyCondition.operators.each do |o|
      @dependency_condition.operator = o
      @dependency_condition.should have(0).errors_on(:operator)
    end
    @dependency_condition.operator = "#"
    @dependency_condition.should have(1).error_on(:operator)
  end

  it "should evaluate within the context of a response set object" do
    @response = Response.new(:question_id => 45, :response_set_id => 40, :answer_id => 23)
    @response.answer = Answer.new(:question_id => 45, :response_class => "answer")
    @response_set = ResponseSet.new()
    @response_set.stub!(:find_response).and_return(@response)
    @dependency_condition.evaluation_of(@response_set).should be_true
    # inversion
    @alt_response = Response.new(:question_id => 45, :response_set_id => 40, :answer_id => 55)
    @alt_response.answer = Answer.new(:question_id => 45, :response_class => "answer")
    @alt_resp_set = ResponseSet.new()

    @alt_resp_set.stub!(:find_response).and_return(@alt_response)
    @dependency_condition.evaluation_of(@alt_resp_set).should be_false

  end
  
  it "should return false if there is no response set value that corresponds to the dependency condition" do
    @empty_rs = mock(ResponseSet, :find_response => nil)
    @dependency_condition.evaluation_of(@empty_rs).should be_false
  end
  
  describe "when helping the dependency object determine state" do
    
    it "returns its key as a symbol" do
      @dependency_condition.symbol_key.should == @dependency_condition.rule_key.to_sym 
    end
    
    it "converts to a hash for evaluation by the depedency object" do
      @rs = mock(ResponseSet)
      @dependency_condition.stub!(:evaluation_of).with(@rs)
      @dependency_condition.to_evaluation_hash(@rs)
    end
    
  end
end

describe DependencyCondition, "evaluting the resonse_set state" do

  describe "when if given a response object whether the dependency is satisfied using '=='" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => "==")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
      @dep_c.as(:answer).should == 2
      @response.as(:answer).should == 2
      @dep_c.as(:answer).should == @response.as(:answer)
    end

    it "knows checkbox/radio type response" do
      @dep_c.is_satisfied_by?(@response).should be_true
      @dep_c.answer_id = 12
      @dep_c.is_satisfied_by?(@response).should be_false
    end

    it "knows string value response" do
      @select_answer.response_class = "string"
      @response.string_value = "hello123"
      @dep_c.string_value = "hello123"
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.string_value = "foo_abc"
      @dep_c.is_satisfied_by?(@response).should be_false
    end

    it "knows a text value response" do
      @select_answer.response_class = "text"
      @response.text_value = "hello this is some text for comparison"
      @dep_c.text_value = "hello this is some text for comparison"
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.text_value = "Not the same text"
      @dep_c.is_satisfied_by?(@response).should be_false 
    end

    it "knows an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 10045
      @dep_c.integer_value = 10045
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.integer_value = 421
      @dep_c.is_satisfied_by?(@response).should be_false
    end

    it "knows a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 121.1
      @dep_c.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.float_value = 130.123
      @dep_c.is_satisfied_by?(@response).should be_false
    end

  end

  describe "when if given a response object whether the dependency is satisfied using '!='" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => "!=")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
      @dep_c.as(:answer).should == 2
      @response.as(:answer).should == 2
      @dep_c.as(:answer).should == @response.as(:answer)
    end

    it "knows checkbox/radio type response" do
      @dep_c.is_satisfied_by?(@response).should be_false
      @dep_c.answer_id = 12
      @dep_c.is_satisfied_by?(@response).should be_true
    end

    it "knows string value response" do
      @select_answer.response_class = "string"
      @response.string_value = "hello123"
      @dep_c.string_value = "hello123"
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.string_value = "foo_abc"
      @dep_c.is_satisfied_by?(@response).should be_true
    end

    it "knows a text value response" do
      @select_answer.response_class = "text"
      @response.text_value = "hello this is some text for comparison"
      @dep_c.text_value = "hello this is some text for comparison"
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.text_value = "Not the same text"
      @dep_c.is_satisfied_by?(@response).should be_true 
    end

    it "knows an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 10045
      @dep_c.integer_value = 10045
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.integer_value = 421
      @dep_c.is_satisfied_by?(@response).should be_true
    end

    it "knows a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 121.1
      @dep_c.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.float_value = 130.123
      @dep_c.is_satisfied_by?(@response).should be_true
    end

  end

  describe "when if given a response object whether the dependency is satisfied using '<'" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => "<")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer

    end

    it "knows operator on integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.integer_value = 421
      @dep_c.is_satisfied_by?(@response).should be_false
    end

    it "knows operator on float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.float_value = 130.123
      @dep_c.is_satisfied_by?(@response).should be_false
    end

  end

  describe "when if given a response object whether the dependency is satisfied using '<='" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => "<=")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer

    end

    it "knows operator on integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.integer_value = 100
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.integer_value = 421
      @dep_c.is_satisfied_by?(@response).should be_false
    end

    it "knows operator on float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.float_value = 130.123
      @dep_c.is_satisfied_by?(@response).should be_false
    end

  end

  describe "when if given a response object whether the dependency is satisfied using '>'" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => ">")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer

    end

    it "knows operator on integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.integer_value = 421
      @dep_c.is_satisfied_by?(@response).should be_true
    end

    it "knows operator on float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.float_value = 130.123
      @dep_c.is_satisfied_by?(@response).should be_true
    end

  end

  describe "when if given a response object whether the dependency is satisfied using '>='" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => ">=")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer

    end

    it "knows operator on integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.integer_value = 100
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.integer_value = 421
      @dep_c.is_satisfied_by?(@response).should be_true
    end

    it "knows operator on float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_false
      @response.float_value = 121.1
      @dep_c.is_satisfied_by?(@response).should be_true
      @response.float_value = 130.123
      @dep_c.is_satisfied_by?(@response).should be_true
    end
  end
  
  

end

