require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Response, "when saving a response" do
  before(:each) do
    @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 1)
  end
  
  it "should be valid" do
    @response.should be_valid
  end
  
  it "should be invalid without a parent response set and question" do
    @response.response_set_id = nil
    @response.should have(1).error_on(:response_set_id)
    
    @response.question_id = nil
    @response.should have(1).error_on(:question_id)
  end

  describe "returns the response as the type requested" do
    
    it "returns 'string'" do
      @response.string_value = "blah"
      @response.as("string").should == "blah"
      @response.as(:string).should == "blah"
    end
    
    it "returns 'integer'" do
      @response.integer_value = 1001
      @response.as(:integer).should == 1001
    end
    
    it "returns 'float'"do
      @response.float_value = 3.14
      @response.as(:float).should == 3.14
    end
    
    it "returns 'answer'" do
      @response.answer_id = 14
      @response.as(:answer).should == 14
    end
    
    it "default returns answer type if not specified" do
      @response.answer_id =18
      @response.as(:stuff).should == 18
    end
    
    it "returns empty elements if the response is cast as a type that is not present" do
      resp = Response.new(:question_id => 314, :response_set_id => 156)
      resp.as(:string).should == nil
      resp.as(:integer).should == nil
      resp.as(:float).should == nil
      resp.as(:answer).should == nil
      resp.as(:stuff).should == nil
    end
        
  end
  
  describe "model validation defined in the answer class attributes" do
    
    before(:each) do
      # faking out all the basic validations on the model
      @response = Response.new(:question_id => 123, :response_set_id => 421, :answer_id => 213)
    end
    
    describe "Integer response_type validations" do
      
      before(:each) do
        @response.stub!(:answer).and_return(mock(Answer, {:response_class => :integer}))
      end
      
      it "validates an upper limit on responses" do
        @response.answer.stub!(:max_value).and_return(10)
        @response.integer_value = 100
        @response.save.should be_false
        @response.should have(1).error_on(:integer_value)
      end
    
    end
    
    describe "Float response_type validations" do

        before(:each) do
          @response.stub!(:answer).and_return(mock(Answer, {:response_class => :float}))
        end

        it "validates an upper limit on responses" do
          pending
        end

      end
    
  end
end
