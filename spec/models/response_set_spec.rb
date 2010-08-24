require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResponseSet do
  before(:each) do
    @response_set = Factory(:response_set)
  end
  it "should have a unique code with length 10 that identifies the survey" do
    @response_set.access_code.should_not be_nil
    @response_set.access_code.length.should == 10
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
  describe "assoication of responses to a survey_section" do
    before(:each) do
      @section = Factory(:survey_section) 
      @response_set.current_section_id = @section.id
    end
    it "should detect existence of responses to questions that belong to a given survey_section" do
      @response_set.update_attributes(:response_attributes => @radio_response_attributes)
      @response_set.no_responses_for_section?(@section).should be_false
    end
    it "should detect absence of responses to questions that belong to a given survey_section" do
      @response_set.update_attributes(:response_attributes => @radio_response_attributes) #responses are associated with @section
      @another_section = Factory(:survey_section) 
      @response_set.no_responses_for_section?(@another_section).should be_true
    end
  end
end

describe ResponseSet, "with dependencies" do
  before(:each) do
    @section = Factory(:survey_section)
    # Questions
    @do_you_like_pie = Factory(:question, :text => "Do you like pie?", :survey_section => @section)
    @what_flavor = Factory(:question, :text => "What flavor?", :survey_section => @section)
    @what_bakery = Factory(:question, :text => "What bakery?", :survey_section => @section)
    # Answers
    @do_you_like_pie.answers << Factory(:answer, :text => "yes", :question_id => @do_you_like_pie.id)
    @do_you_like_pie.answers << Factory(:answer, :text => "no", :question_id => @do_you_like_pie.id)
    @what_flavor.answers << Factory(:answer, :response_class => :string, :question_id => @what_flavor.id)
    @what_bakery.answers << Factory(:answer, :response_class => :string, :question_id => @what_bakery.id)
    # Dependency
    @what_flavor_dep = Factory(:dependency, :rule => "A", :question_id => @what_flavor.id)
    Factory(:dependency_condition, :rule_key => "A", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_flavor_dep.id)
    @what_bakery_dep = Factory(:dependency, :rule => "B", :question_id => @what_bakery.id)
    Factory(:dependency_condition, :rule_key => "B", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_bakery_dep.id)
    # Responses
    @response_set = Factory(:response_set)
    @response_set.current_section_id = @section.id
    @response_set.responses << Factory(:response, :question_id => @do_you_like_pie.id, :answer_id => @do_you_like_pie.answers.first.id, :response_set_id => @response_set.id)
    @response_set.responses << Factory(:response, :string_value => "pecan pie", :question_id => @what_flavor.id, :answer_id => @what_flavor.answers.first.id, :response_set_id => @response_set.id)
  end
  
  it "should list unanswered dependencies to show at the top of the next page (javascript turned off)" do
    @response_set.unanswered_dependencies.should == [@what_bakery]
  end
  it "should list answered and unanswered dependencies to show inline (javascript turned on)" do
    @response_set.all_dependencies[:show].should == ["question_#{@what_flavor.id}", "question_#{@what_bakery.id}"]
  end
  
end
describe ResponseSet, "as a quiz" do
  before(:each) do
    @survey = Factory(:survey)
    @section = Factory(:survey_section, :survey => @survey)
    @response_set = Factory(:response_set, :survey => @survey)
  end
  def generate_responses(count, quiz = nil, correct = nil)
    count.times do |i|
      q = Factory(:question, :survey_section => @section)
      a = Factory(:answer, :question => q, :response_class => "answer")
      x = Factory(:answer, :question => q, :response_class => "answer")
      q.correct_answer_id = (quiz == "quiz" ? a.id : nil)
      @response_set.responses << Factory(:response, :question => q, :answer => (correct == "correct" ? a : x))
    end
  end
  
  it "should report correctness if it is a quiz" do
    generate_responses(3, "quiz", "correct")
    @response_set.correct?.should be_true
    @response_set.correctness_hash.should == {:questions => 3, :responses => 3, :correct => 3}
  end
  it "should report incorrectness if it is a quiz" do
    generate_responses(3, "quiz", "incorrect")
    @response_set.correct?.should be_false
    @response_set.correctness_hash.should == {:questions => 3, :responses => 3, :correct => 0}
  end
  it "should report correct if it isn't a quiz" do
    generate_responses(3, "non-quiz")
    @response_set.correct?.should be_true
    @response_set.correctness_hash.should == {:questions => 3, :responses => 3, :correct => 3}
  end
end
describe ResponseSet, "with mandatory questions" do
  before(:each) do
    @survey = Factory(:survey)
    @section = Factory(:survey_section, :survey => @survey)
    @response_set = Factory(:response_set, :survey => @survey)
  end
  def generate_responses(count, mandatory = nil, responded = nil)
    count.times do |i|
      q = Factory(:question, :survey_section => @section, :is_mandatory => (mandatory == "mandatory"))
      a = Factory(:answer, :question => q, :response_class => "answer")
      if responded == "responded"
        @response_set.responses << Factory(:response, :question => q, :answer => a)
      end
    end
  end
  it "should report progress without mandatory questions" do
    generate_responses(3)
    @response_set.mandatory_questions_complete?.should be_true
    @response_set.progress_hash.should == {:questions => 3, :triggered => 3, :triggered_mandatory => 0, :triggered_mandatory_completed => 0}
  end
  it "should report progress with mandatory questions" do
    generate_responses(3, "mandatory", "responded")
    @response_set.mandatory_questions_complete?.should be_true
    @response_set.progress_hash.should == {:questions => 3, :triggered => 3, :triggered_mandatory => 3, :triggered_mandatory_completed => 3}
  end
  it "should report progress with mandatory questions" do
    generate_responses(3, "mandatory", "not-responded")
    @response_set.mandatory_questions_complete?.should be_false
    @response_set.progress_hash.should == {:questions => 3, :triggered => 3, :triggered_mandatory => 3, :triggered_mandatory_completed => 0}
  end
  it "should ignore labels and images" do
    generate_responses(3, "mandatory", "responded")
    Factory(:question, :survey_section => @section, :display_type => "label", :is_mandatory => true)
    Factory(:question, :survey_section => @section, :display_type => "image", :is_mandatory => true)
    @response_set.mandatory_questions_complete?.should be_true
    @response_set.progress_hash.should == {:questions => 5, :triggered => 5, :triggered_mandatory => 5, :triggered_mandatory_completed => 5}
  end
end
describe ResponseSet, "with mandatory, dependent questions" do
  before(:each) do
    @survey = Factory(:survey)
    @section = Factory(:survey_section, :survey => @survey)
    @response_set = Factory(:response_set, :survey => @survey)
  end
  def generate_responses(count, mandatory = nil, dependent = nil, triggered = nil)
    dq = Factory(:question, :survey_section => @section, :is_mandatory => (mandatory == "mandatory"))
    da = Factory(:answer, :question => dq, :response_class => "answer")
    dx = Factory(:answer, :question => dq, :response_class => "answer")
    count.times do |i|
      q = Factory(:question, :survey_section => @section, :is_mandatory => (mandatory == "mandatory"))
      a = Factory(:answer, :question => q, :response_class => "answer")
      if dependent == "dependent"
        d = Factory(:dependency, :question => q)
        dc = Factory(:dependency_condition, :dependency => d, :question_id => dq.id, :answer_id => da.id)
      end
      @response_set.responses << Factory(:response, :question => dq, :answer => (triggered == "triggered" ? da : dx))
      @response_set.responses << Factory(:response, :question => q, :answer => a)
    end
  end
  it "should report progress without mandatory questions" do
    generate_responses(3, "mandatory", "dependent")
    @response_set.mandatory_questions_complete?.should be_true
    @response_set.progress_hash.should == {:questions => 4, :triggered => 1, :triggered_mandatory => 1, :triggered_mandatory_completed => 1}
  end
  it "should report progress with mandatory questions" do
    generate_responses(3, "mandatory", "dependent", "triggered")
    @response_set.mandatory_questions_complete?.should be_true
    @response_set.progress_hash.should == {:questions => 4, :triggered => 4, :triggered_mandatory => 4, :triggered_mandatory_completed => 4}
  end
end
describe ResponseSet, "exporting csv" do
  before(:each) do
    @section = Factory(:survey_section)
    # Questions
    @do_you_like_pie = Factory(:question, :text => "Do you like pie?", :survey_section => @section)
    @what_flavor = Factory(:question, :text => "What flavor?", :survey_section => @section)
    @what_bakery = Factory(:question, :text => "What bakery?", :survey_section => @section)
    # Answers
    @do_you_like_pie.answers << Factory(:answer, :text => "yes", :question_id => @do_you_like_pie.id)
    @do_you_like_pie.answers << Factory(:answer, :text => "no", :question_id => @do_you_like_pie.id)
    @what_flavor.answers << Factory(:answer, :response_class => :string, :question_id => @what_flavor.id)
    @what_bakery.answers << Factory(:answer, :response_class => :string, :question_id => @what_bakery.id)
    # Responses
    @response_set = Factory(:response_set)
    @response_set.current_section_id = @section.id
    @response_set.responses << Factory(:response, :question_id => @do_you_like_pie.id, :answer_id => @do_you_like_pie.answers.first.id, :response_set_id => @response_set.id)
    @response_set.responses << Factory(:response, :string_value => "pecan pie", :question_id => @what_flavor.id, :answer_id => @what_flavor.answers.first.id, :response_set_id => @response_set.id)
  end
  it "should export a string with responses" do
    @response_set.responses.size.should == 2
    csv = @response_set.to_csv
    csv.is_a?(String).should be_true
    csv.should match "question.short_text"
    csv.should match "What flavor?"
    csv.should match /pecan pie/    
  end
end
