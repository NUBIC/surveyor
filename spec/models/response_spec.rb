require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Response, "when saving a response" do
  before(:each) do
    # @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 1)
    @response = Factory(:response, :question => Factory(:question), :answer => Factory(:answer))
  end

  it "should be valid" do
    @response.should be_valid
  end

  it "should be invalid without a question" do
    @response.question_id = nil
    @response.should have(1).error_on(:question_id)
  end

  it "should be correct if the question has no correct_answer_id" do
    @response.question.correct_answer_id.should be_nil
    @response.correct?.should be_true
  end

  it "should be correct if the answer's response class != answer" do
    @response.answer.response_class.should_not == "answer"
    @response.correct?.should be_true
  end

  it "should be (in)correct if answer_id is (not) equal to question's correct_answer_id" do
    @answer = Factory(:answer, :response_class => "answer")
    @question = Factory(:question, :correct_answer => @answer)
    @response = Factory(:response, :question => @question, :answer => @answer)
    @response.correct?.should be_true
    @response.answer = Factory(:answer, :response_class => "answer").tap { |a| a.id = 143 }
    @response.correct?.should be_false
  end
  
  it "should be in order by created_at" do
    @response.response_set.should_not be_nil
    response2 = Factory(:response, :question => Factory(:question), :answer => Factory(:answer), :response_set => @response.response_set, :created_at => (@response.created_at + 1))
    Response.all.should == [@response, response2]
  end
  
  it "should protect api_id, timestamps" do
    saved_attrs = @response.attributes
    if defined? ActiveModel::MassAssignmentSecurity::Error
      lambda {@response.update_attributes(:created_at => 3.days.ago, :updated_at => 3.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@response.update_attributes(:api_id => "NEW")}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    else
      @response.attributes = {:created_at => 3.days.ago, :updated_at => 3.hours.ago} # automatically protected by Rails
      @response.attributes = {:api_id => "NEW"} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
    end
    @response.attributes.should == saved_attrs
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

    it "returns 'float'" do
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
end

describe Response, "applicable_attributes" do
  before(:each) do
    @who = Factory(:question, :text => "Who rules?")
    @odoyle = Factory(:answer, :text => "Odoyle", :response_class => "answer")
    @other = Factory(:answer, :text => "Other", :response_class => "string")
  end

  it "should have string_value if response_type is string" do
    good = {"question_id" => @who.id, "answer_id" => @other.id, "string_value" => "Frank"}
    Response.applicable_attributes(good).should == good
  end

  it "should not have string_value if response_type is answer" do
    bad = {"question_id"=>@who.id, "answer_id"=>@odoyle.id, "string_value"=>"Frank"}
    Response.applicable_attributes(bad).
      should == {"question_id" => @who.id, "answer_id"=> @odoyle.id}
  end

  it "should have string_value if response_type is string and answer_id is an array (in the case of checkboxes)" do
    good = {"question_id"=>@who.id, "answer_id"=>["", @odoyle.id], "string_value"=>"Frank"}
    Response.applicable_attributes(good).
      should == {"question_id" => @who.id, "answer_id"=> ["", @odoyle.id]}
  end

  it "should have ignore attribute if missing answer_id" do
    ignore = {"question_id"=>@who.id, "answer_id"=>"", "string_value"=>"Frank"}
    Response.applicable_attributes(ignore).
      should == {"question_id"=>@who.id, "answer_id"=>"", "string_value"=>"Frank"}
  end

  it "should have ignore attribute if missing answer_id is an array" do
    ignore = {"question_id"=>@who.id, "answer_id"=>[""], "string_value"=>"Frank"}
    Response.applicable_attributes(ignore).
      should == {"question_id"=>@who.id, "answer_id"=>[""], "string_value"=>"Frank"}
  end
end

describe Response, '#json_value' do
  context "when integer" do
    let(:r) {Response.new(:integer_value => 2, :answer => Answer.new(:response_class => 'integer'))}
    it "should be 2" do
      r.json_value.should == 2
    end
  end

  context "when float" do
    let(:r) {Response.new(:float_value => 3.14, :answer => Answer.new(:response_class => 'float'))}
    it "should be 3.14" do
      r.json_value.should == 3.14
    end
  end

  context "when string" do
    let(:r) {Response.new(:string_value => 'bar', :answer => Answer.new(:response_class => 'string'))}
    it "should be 'bar'" do
      r.json_value.should == 'bar'
    end
  end

  context "when datetime" do
    let(:r) {Response.new(:datetime_value => DateTime.strptime('2010-04-08T10:30+00:00', '%Y-%m-%dT%H:%M%z'), :answer => Answer.new(:response_class => 'datetime'))}
    it "should be '2010-04-08T10:30+00:00'" do
      r.json_value.should == '2010-04-08T10:30+00:00'
      r.json_value.to_json.should == '"2010-04-08T10:30+00:00"'
    end
  end

  context "when date" do
    let(:r) {Response.new(:datetime_value => DateTime.strptime('2010-04-08', '%Y-%m-%d'), :answer => Answer.new(:response_class => 'date'))}
    it "should be '2010-04-08'" do
      r.json_value.should == '2010-04-08'
      r.json_value.to_json.should == '"2010-04-08"'
    end
  end

  context "when time" do
    let(:r) {Response.new(:datetime_value => DateTime.strptime('10:30', '%H:%M'), :answer => Answer.new(:response_class => 'time'))}
    it "should be '10:30'" do
      r.json_value.should == '10:30'
      r.json_value.to_json.should == '"10:30"'
    end
  end
end
