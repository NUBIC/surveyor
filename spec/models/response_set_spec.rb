require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResponseSet, "class methods" do
  before(:each) do
    @survey = mock_model(Survey, :access_code => "XYZ")
    @response_set = ResponseSet.new(:access_code => "PDQ", :survey => @survey)
    ResponseSet.stub!(:find_by_access_code).with("PDQ").and_return(@response_set)
  end
  it "should find a response set by response_set.access_code or return false" do
    ResponseSet.find_by_access_code("PDQ").should == @response_set
    ResponseSet.find_by_access_code("Different").should be_nil
  end
end
describe ResponseSet, "when saving" do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :survey_id => 1,
    }
    @response_set = ResponseSet.new(@valid_attributes)
  end
  
  it "should be valid" do
    @response_set.should be_valid
  end
  it "should be invalid without a parent user and survey" do
    @response_set.user_id = nil
    @response_set.survey_id = nil
    @response_set.should have(1).error_on(:user_id)
    @response_set.should have(1).error_on(:survey_id)
  end

  it "should have a default started at date/time" do
    @response_set.started_at.blank?.should_not == true
    @response_set.started_at.localtime.to_date.should == Date.today
  end

  it "should have no errors after save" do
    user = mock_model(User)
    survey = mock_model(Survey)

    @response_set.user = user #User.find(1)
    @response_set.survey = survey #Survey.find(1)
    @response_set.save.should be_true
    @response_set.errors.should be_empty
  end

end
describe ResponseSet, "with responses" do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :survey_id => 1,
    }
    @response_set = ResponseSet.new(@valid_attributes)
  end

  it "can tell you its responses" do
    3.times{ |x| @response_set.responses.build }  
    @response_set.responses.should have(3).items
  end

  it "is completable" do
    @response_set.completed_at.should be_nil
    @response_set.complete!
    @response_set.completed_at.should_not be_nil
    @response_set.completed_at.is_a?(Time).should be_true
  end

  it "allows completion through mass assignment" do
    @response_set.completed_at.should be_nil
    @response_set.update_attributes(:completed_at => Time.now)
    @response_set.completed_at.should be_nil
  end

end
describe ResponseSet, "Creating new set for user" do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :survey_id => 1,
    }
    @response_set = ResponseSet.new(@valid_attributes)
  end
  it "should have a unique code with length 10 that identifies the survey" do
    @response_set.access_code.should_not be_nil
    @response_set.access_code.length.should == 10
  end
end
describe ResponseSet, "Updating the response set" do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :survey_id => 1,
    }
    # {"responses"=>{
    #   "6"=>{"question_id"=>"6", "20"=>{"string_value"=>""}}, 
    #   "7"=>{"question_id"=>"7", "21"=>{"text_value"=>"Brian is tired"}}, 
    #   "1"=>{"question_id"=>"1", "answer_id"=>"1", "4"=>{"string_value"=>"XXL"}}, 
    #   "2"=>{"question_id"=>"2", "answer_id"=>"6"}, 
    #   "3"=>{"question_id"=>"3"}, 
    #   "4"=>{"question_id"=>"4"}, 
    #   "5"=>{"question_id"=>"5", "19"=>{"string_value"=>""}}}, 
    # "survey_code"=>"test_survey", 
    # "commit"=>"Next Section (Utensiles and you!) >>", 
    # "authenticity_token"=>"d03bc1b52fa9669e1ed87c313b939836e7b93e34", 
    # "_method"=>"put", 
    # "action"=>"update", 
    # "controller"=>"app", 
    # "response_set_code"=>"cIFn0DnxlU", 
    # "section"=>"2"}
      
    #TODO test views to produce these params. e.g., blank responses should still have a hash with question_id
    @radio_response_attributes = HashWithIndifferentAccess.new({
      "1"=>{"question_id"=>"1", "answer_id"=>"1", "4"=>{"string_value"=>"XXL"}}, 
      "2"=>{"question_id"=>"2", "answer_id"=>"6"}, 
      "3"=>{"question_id"=>"3"}
    })
    @other_response_attributes = HashWithIndifferentAccess.new({
      "6"=>{"question_id"=>"6", "20"=>{"string_value"=>""}}, 
      "7"=>{"question_id"=>"7", "21"=>{"text_value"=>"Brian is tired"}}, 
      "5"=>{"question_id"=>"5", "19"=>{"string_value"=>""}}   
    })
    @response_set = ResponseSet.new(@valid_attributes)
  end

  it "should delete existing responses corresponding to every question key that comes in" do
    Response.should_receive(:delete_all).exactly(3).times
    @response_set.update_attributes(:response_attributes => @radio_response_attributes)
  end
  it "should save new responses from radio buttons, ignoring blanks" do
    @response_set.update_attributes(:response_attributes => @radio_response_attributes)
    @response_set.responses.should have(2).items
    @response_set.responses.detect{|r| r.question_id == 2}.answer_id.should == 6
  end
  it "should save new responses from other types, ignoring blanks" do
    @response_set.update_attributes(:response_attributes => @other_response_attributes)
    @response_set.responses.should have(1).items
    @response_set.responses.detect{|r| r.question_id == 7}.text_value.should == "Brian is tired"
  end
  it "should ignore data if corresponding radio button is not selected" do
    @response_set.update_attributes(:response_attributes => @radio_response_attributes)
    @response_set.responses.select{|r| r.question_id == 2}.should have(1).item
    @response_set.responses.detect{|r| r.question_id == 2}.string_value.should == nil
  end
  it "should preserve data in checkboxes regardless of selection" do
    pending
  end

  it "should give convenient access to responses through response_for" do
    @response_set.save #need to save for the associated models to build/save
    @response_set.attributes = {:response_attributes => @radio_response_attributes}
    @response_set.save.should be_true
    @response_set.responses.should have(2).items
    
    pending
  end
end

describe ResponseSet, "knowing internal status" do

  it "knows when it is empty"  do
    @response_set = ResponseSet.new
    @response_set.empty?.should be_true
  end

  it "knows when it is not empty" do
    @response_set = ResponseSet.new
    @response_set.responses.build({:question_id => 1, :answer_id => 8})
    @response_set.empty?.should be_false
  end
end