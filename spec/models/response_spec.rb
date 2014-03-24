require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Response, "when saving a response" do
  before(:each) do
    # @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 1)
    @response = FactoryGirl.create(:response, :question => FactoryGirl.create(:question), :answer => FactoryGirl.create(:answer))
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
    @answer = FactoryGirl.create(:answer, :response_class => "answer")
    @question = FactoryGirl.create(:question, :correct_answer => @answer)
    @response = FactoryGirl.create(:response, :question => @question, :answer => @answer)
    @response.correct?.should be_true
    @response.answer = FactoryGirl.create(:answer, :response_class => "answer").tap { |a| a.id = 143 }
    @response.correct?.should be_false
  end
  
  it "should be in order by created_at" do
    @response.response_set.should_not be_nil
    response2 = FactoryGirl.create(:response, :question => FactoryGirl.create(:question), :answer => FactoryGirl.create(:answer), :response_set => @response.response_set, :created_at => (@response.created_at + 1))
    Response.all.should == [@response, response2]
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
    @who = FactoryGirl.create(:question, :text => "Who rules?")
    @odoyle = FactoryGirl.create(:answer, :text => "Odoyle", :response_class => "answer")
    @other = FactoryGirl.create(:answer, :text => "Other", :response_class => "string")
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

describe Response, '#to_formatted_s' do
  context "when datetime" do
    let(:r) { Response.new(:answer => Answer.new(:response_class => 'datetime')) }

    it 'returns "" when nil' do
      r.datetime_value = nil

      r.to_formatted_s.should == ""
    end
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

describe Response, 'value methods' do
  let(:response) { Response.new }

  describe '#date_value=' do
    it 'accepts a parseable date string' do
      response.date_value = '2010-01-15'
      response.datetime_value.strftime('%Y %m %d').should == '2010 01 15'
    end

    it 'clears when given nil' do
      response.datetime_value = Time.new
      response.date_value = nil
      response.datetime_value.should be_nil
    end
  end

  describe 'time_value=' do
    it 'accepts a parseable time string' do
      response.time_value = '11:30'
      response.datetime_value.strftime('%H %M %S').should == '11 30 00'
    end

    it 'clears when given nil' do
      response.datetime_value = Time.new
      response.time_value = nil
      response.datetime_value.should be_nil
    end
  end
end
