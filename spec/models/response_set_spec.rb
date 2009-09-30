require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResponseSet, "class methods" do
  before(:each) do
    @response_set = Factory(:response_set, :access_code => "PDQ")
  end
  it "should find a response set by response_set.access_code or return false" do
    ResponseSet.find_by_access_code("PDQ").should == @response_set
    ResponseSet.find_by_access_code("Different").should be_nil
  end
end
describe ResponseSet, "with responses" do
  before(:each) do
    @response_set = Factory(:response_set)
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

  it "does not allow completion through mass assignment" do
    @response_set.completed_at.should be_nil
    @response_set.update_attributes(:completed_at => Time.now)
    @response_set.completed_at.should be_nil
  end

end
describe ResponseSet, "Creating new set for user" do
  before(:each) do
    @response_set = Factory(:response_set)
  end
  it "should have a unique code with length 10 that identifies the survey" do
    @response_set.access_code.should_not be_nil
    @response_set.access_code.length.should == 10
  end
end
describe ResponseSet, "Updating the response set" do
  before(:each) do
    @response_set = Factory(:response_set)
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
  before(:each) do
    @response_set = Factory(:response_set)
  end
  it "knows when it is empty"  do
    @response_set.empty?.should be_true
  end

  it "knows when it is not empty" do
    @response_set.responses.build({:question_id => 1, :answer_id => 8})
    @response_set.empty?.should be_false
  end
end
describe ResponseSet, "with dependencies" do
  before(:each) do
    # Questions
    @do_you_like_pie = Factory(:question, :text => "Do you like pie?")
    @what_flavor = Factory(:question, :text => "What flavor?")
    @what_bakery = Factory(:question, :text => "What bakery?")
    # Answers
    @do_you_like_pie.answers << Factory(:answer, :text => "yes", :question_id => @do_you_like_pie.id)
    @do_you_like_pie.answers << Factory(:answer, :text => "no", :question_id => @do_you_like_pie.id)
    @what_flavor.answers << Factory(:answer, :response_class => :string, :question_id => @what_flavor.id)
    @what_bakery.answers << Factory(:answer, :response_class => :string, :question_id => @what_bakery.id)
    # Dependency
    @what_flavor_dep = Factory(:dependency, :rule => "1", :question_id => @what_flavor.id)
    @what_flavor_dep.dependency_conditions << Factory(:dependency_condition, :rule_key => "1", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_flavor_dep.id)
    @what_bakery_dep = Factory(:dependency, :rule => "2", :question_id => @what_bakery.id)
    @what_bakery_dep.dependency_conditions << Factory(:dependency_condition, :rule_key => "2", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_bakery_dep.id)
    # Responses
    @response_set = Factory(:response_set)
    @response_set.responses << Factory(:response, :question_id => @do_you_like_pie.id, :answer_id => @do_you_like_pie.answers.first.id, :response_set_id => @response_set.id)
    @response_set.responses << Factory(:response, :string_value => "pecan pie", :question_id => @what_flavor.id, :answer_id => @what_flavor.answers.first.id, :response_set_id => @response_set.id)
  end
  
  it "should list unanswered dependencies to show at the top of the next page (javascript turned off)" do
    @response_set.unanswered_dependencies.should == [@what_bakery]
  end
  it "should list answered and unanswered dependencies to show inline (javascript turned on)" do
    @response_set.all_dependencies[:show].should == [@what_flavor, @what_bakery]
  end
  
end