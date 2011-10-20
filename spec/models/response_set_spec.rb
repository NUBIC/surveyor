require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResponseSet do
  before(:each) do
    @response_set = Factory(:response_set)
    @radio_response_attributes = HashWithIndifferentAccess.new({"1"=>{"question_id"=>"1", "answer_id"=>"1", "string_value"=>"XXL"}, "2"=>{"question_id"=>"2", "answer_id"=>"6"}, "3"=>{"question_id"=>"3"}})
    @checkbox_response_attributes = HashWithIndifferentAccess.new({"1"=>{"question_id"=>"9", "answer_id"=>"11"}, "2"=>{"question_id"=>"9", "answer_id"=>"12"}})
    @other_response_attributes = HashWithIndifferentAccess.new({"6"=>{"question_id"=>"6", "answer_id" => "3", "string_value"=>""}, "7"=>{"question_id"=>"7", "answer_id" => "4", "text_value"=>"Brian is tired"}, "5"=>{"question_id"=>"5", "answer_id" => "5", "string_value"=>""}})
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
    @response_set.should be_complete
  end

  it "does not allow completion through mass assignment" do
    @response_set.completed_at.should be_nil
    @response_set.update_attributes(:completed_at => Time.now)
    @response_set.completed_at.should be_nil
  end

  it "should save new responses from radio buttons, ignoring blanks" do
    @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable(@radio_response_attributes))
    @response_set.responses.should have(2).items
    @response_set.responses.detect{|r| r.question_id == 2}.answer_id.should == 6
  end

  it "should save new responses from other types, ignoring blanks" do
    @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable(@other_response_attributes))
    @response_set.responses.should have(1).items
    @response_set.responses.detect{|r| r.question_id == 7}.text_value.should == "Brian is tired"
  end

  it "should ignore data if corresponding radio button is not selected" do
    @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable(@radio_response_attributes))
    @response_set.responses.select{|r| r.question_id == 2}.should have(1).item
    @response_set.responses.detect{|r| r.question_id == 2}.string_value.should == nil
  end

  it "should preserve response ids in checkboxes when adding another checkbox" do
    @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable(@checkbox_response_attributes))
    @response_set.responses.should have(2).items
    initial_response_ids = @response_set.responses.map(&:id)
    # adding a checkbox
    @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable({"1"=>{"question_id"=>"9", "answer_id"=>"13"}}))
    @response_set.responses.should have(3).items
    (@response_set.responses.map(&:id) - initial_response_ids).size.should == 1
  end

  it "should preserve response ids in checkboxes when removing another checkbox" do
    @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable(@checkbox_response_attributes))
    @response_set.responses.should have(2).items
    initial_response_ids = @response_set.responses.map(&:id)
    # removing a checkbox, reload the response set
    @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable({"1"=>{"question_id"=>"9", "answer_id"=>"", "id" => initial_response_ids.first}}))
    @response_set.reload.responses.should have(1).items
    (initial_response_ids - @response_set.responses.map(&:id)).size.should == 1
  end
  it "should clean up a blank or empty hash" do
    ResponseSet.to_savable(nil).should == []
    ResponseSet.to_savable({}).should == []
  end

  it "should clean up responses_attributes before passing to nested_attributes" do
    hash_of_hashes = {
      "11" => {"question_id" => "1", "answer_id" => [""]}, # new checkbox, blank
      "12" => {"question_id" => "2", "answer_id" => ["", "124"]}, # new checkbox, checked
      "13" => {"id" => "101", "question_id" => "3", "answer_id" => [""]}, # existing checkbox, unchecked
      "14" => {"id" => "102", "question_id" => "4", "answer_id" => ["", "147"]}, # existing checkbox, left alone
      "15" => {"question_id" => "5", "answer_id" => ""}, # new radio, blank
      "16" => {"question_id" => "6", "answer_id" => "161"}, # new radio, selected
      "17" => {"id" => "103", "question_id" => "7", "answer_id" => "171"}, # existing radio, changed
      "18" => {"id" => "104", "question_id" => "8", "answer_id" => "181"}, # existing radio, unchanged
      "19" => {"question_id" => "9", "answer_id" => "191", "string_value" => ""}, # new string, blank
      "20" => {"question_id" => "10", "answer_id" => "201", "string_value" => "hi"}, # new string, filled
      "21" => {"id" => "105", "question_id" => "11", "answer_id" => "211", "string_value" => ""}, # existing string, cleared
      "22" => {"id" => "106", "question_id" => "12", "answer_id" => "221", "string_value" => "ho"}, # existing string, changed
      "23" => {"id" => "107", "question_id" => "13", "answer_id" => "231", "string_value" => "hi"}, # existing string, unchanged
      "24" => {"question_id" => "14", "answer_id" => [""], "string_value" => "foo"}, # new checkbox with string value, blank
      "25" => {"question_id" => "15", "answer_id" => ["", "241"], "string_value" => "bar"}, # new checkbox with string value, checked
      "26" => {"id" => "108", "question_id" => "14", "answer_id" => [""], "string_value" => "moo"}, # existing checkbox with string value, unchecked
      "27" => {"id" => "109", "question_id" => "15", "answer_id" => ["", "251"], "string_value" => "mar"}, # existing checkbox with string value, left alone
      "28" => {"question_id" => "16", "answer_id" => "", "string_value" => "foo"}, # new radio with string value, blank
      "29" => {"question_id" => "17", "answer_id" => "261", "string_value" => "bar"}, # new radio with string value, selected
      "30" => {"id" => "110", "question_id" => "18", "answer_id" => "271", "string_value" => "moo"}, # existing radio with string value, changed
      "31" => {"id" => "111", "question_id" => "19", "answer_id" => "281", "string_value" => "mar"} # existing radio with string value, unchanged
    }

    Set.new(ResponseSet.to_savable(hash_of_hashes)).should == Set.new([
      # "11" => {"question_id" => "1", "answer_id" => [""]}, # new checkbox, blank
      {"question_id"=>"2", "answer_id"=>["", "124"]}, # new checkbox, checked
      {"question_id"=>"3", "id"=>"101", "_destroy"=>"1"}, # existing checkbox, unchecked
      {"question_id"=>"4", "id"=>"102", "answer_id"=>["", "147"]}, # existing checkbox, left alone
      # "15" => {"question_id" => "5", "answer_id" => ""}, # new radio, blank
      {"question_id"=>"6", "answer_id"=>"161"}, # new radio, selected
      {"question_id"=>"7", "id"=>"103", "answer_id"=>"171"}, # existing radio, changed
      {"question_id"=>"8", "id"=>"104", "answer_id"=>"181"}, # existing radio, unchanged
      # "19" => {"question_id" => "9", "answer_id" => "191", "string_value" => ""}, # new string, blank
      {"question_id"=>"10", "string_value"=>"hi", "answer_id"=>"201"}, # new string, filled
      {"question_id"=>"11", "string_value"=>"", "id"=>"105", "_destroy"=>"1"}, # existing string, cleared
      {"question_id"=>"12", "id"=>"106", "string_value"=>"ho", "answer_id"=>"221"}, # existing string, changed
      {"question_id"=>"13", "id"=>"107", "string_value"=>"hi", "answer_id"=>"231"}, # existing string, unchanged
      # "24" => {"question_id" => "14", "answer_id" => [""], "string_value" => "foo"}, # new checkbox with string value, blank
      {"question_id"=>"15", "string_value"=>"bar", "answer_id"=>["", "241"]}, # new checkbox with string value, checked
      {"question_id"=>"14", "string_value"=>"moo", "id"=>"108", "_destroy"=>"1"}, # existing checkbox with string value, unchecked
      {"question_id"=>"15", "id"=>"109", "string_value"=>"mar", "answer_id"=>["", "251"]},# existing checkbox with string value, left alone
      # "28" => {"question_id" => "16", "answer_id" => "", "string_value" => "foo"}, # new radio with string value, blank
      {"question_id"=>"17", "string_value"=>"bar", "answer_id"=>"261"}, # new radio with string value, selected
      {"question_id"=>"18", "id"=>"110", "string_value"=>"moo", "answer_id"=>"271"}, # existing radio with string value, changed
      {"question_id"=>"19", "id"=>"111", "string_value"=>"mar", "answer_id"=>"281"} # existing radio with string value, unchanged
    ])
  end

  it "should clean up radio and string responses_attributes before passing to nested_attributes" do
    @qone = Factory(:question, :pick => "one")
    hash_of_hashes = {
      "32" => {"question_id" => @qone.id, "answer_id" => "291", "string_value" => ""} # new radio with blank string value, selected
    }
    ResponseSet.to_savable(hash_of_hashes).should == [
      {"question_id" => @qone.id, "answer_id" => "291", "string_value" => ""} # new radio with blank string value, selected
    ]
  end

  it "should clean up responses for lookups to get ids after saving via ajax" do
    hash_of_hashes = {"1"=>{"question_id"=>"2", "answer_id"=>"1"},
      "2"=>{"question_id"=>"3", "answer_id"=>["", "6"]},
      "9"=>{"question_id"=>"6", "string_value"=>"jack", "answer_id"=>"13"},
      "17"=>{"question_id"=>"13", "datetime_value(1i)"=>"2006", "datetime_value(2i)"=>"2", "datetime_value(3i)"=>"4", "datetime_value(4i)"=>"02", "datetime_value(5i)"=>"05", "answer_id"=>"21"},
      "18"=>{"question_id"=>"14", "datetime_value(1i)"=>"1", "datetime_value(2i)"=>"1", "datetime_value(3i)"=>"1", "datetime_value(4i)"=>"01", "datetime_value(5i)"=>"02", "answer_id"=>"22"},
      "19"=>{"question_id"=>"15", "datetime_value"=>"", "answer_id"=>"23", "id" => "1"},
      "47"=>{"question_id"=>"38", "answer_id"=>"220", "integer_value"=>"2", "id" => "2"},
      "61"=>{"question_id"=>"44", "response_group"=>"0", "answer_id"=>"241", "integer_value"=>"12"}}
    ResponseSet.trim_for_lookups(hash_of_hashes).should ==
    { "1"=>{"question_id"=>"2", "answer_id"=>"1"},
      "2"=>{"question_id"=>"3", "answer_id"=>["", "6"]},
      "9"=>{"question_id"=>"6", "answer_id"=>"13"},
      "17"=>{"question_id"=>"13", "answer_id"=>"21"},
      "18"=>{"question_id"=>"14", "answer_id"=>"22"},
      "19"=>{"question_id"=>"15", "answer_id"=>"23", "id" => "1", "_destroy" => "true"},
      "47"=>{"question_id"=>"38", "answer_id"=>"220", "id" => "2"},
      "61"=>{"question_id"=>"44", "response_group"=>"0", "answer_id"=>"241"}
    }
  end

  it "should remove responses" do
    r = @response_set.responses.create(:question_id => 1, :answer_id => 2)
    r.id.should_not be nil
    @response_set.should have(1).responses
    ResponseSet.to_savable({"2"=>{"question_id"=>"1", "id"=> r.id, "answer_id"=>[""]}}).should == [{"question_id"=>"1", "id"=> r.id, "_destroy"=> "1" }]
    @response_set.update_attributes(:responses_attributes => [{"question_id"=>"1", "id"=> r.id, "_destroy"=> "1"}]).should be_true
    @response_set.reload.should have(0).responses
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
    @response_set.responses << Factory(:response, :question_id => @do_you_like_pie.id, :answer_id => @do_you_like_pie.answers.first.id, :response_set_id => @response_set.id)
    @response_set.responses << Factory(:response, :string_value => "pecan pie", :question_id => @what_flavor.id, :answer_id => @what_flavor.answers.first.id, :response_set_id => @response_set.id)
  end

  it "should list unanswered dependencies to show at the top of the next page (javascript turned off)" do
    @response_set.unanswered_dependencies.should == [@what_bakery]
  end
  it "should list answered and unanswered dependencies to show inline (javascript turned on)" do
    @response_set.all_dependencies[:show].should == ["q_#{@what_flavor.id}", "q_#{@what_bakery.id}"]
  end
  it "should list group as dependency" do
    # Question Group
    crust_group = Factory(:question_group, :text => "Favorite Crusts")

    # Question
    what_crust = Factory(:question, :text => "What is your favorite curst type?", :survey_section => @section)
    crust_group.questions << what_crust

    # Answers
    what_crust.answers << Factory(:answer, :response_class => :string, :question_id => what_crust.id)

    # Dependency
    crust_group_dep = Factory(:dependency, :rule => "C", :question_group_id => crust_group.id, :question => nil)
    Factory(:dependency_condition, :rule_key => "C", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => crust_group_dep.id)

    @response_set.unanswered_dependencies.should == [@what_bakery, crust_group]
  end
end
describe ResponseSet, "dependency_conditions" do
  before do
    @section = Factory(:survey_section)
    # Questions
    @like_pie = Factory(:question, :text => "Do you like pie?", :survey_section => @section)
    @like_jam = Factory(:question, :text => "Do you like jam?", :survey_section => @section)
    @what_is_wrong_with_you = Factory(:question, :text => "What's wrong with you?", :survey_section => @section)
    # Answers
    @like_pie.answers << Factory(:answer, :text => "yes", :question_id => @like_pie.id)
    @like_pie.answers << Factory(:answer, :text => "no", :question_id => @like_pie.id)
    @like_jam.answers << Factory(:answer, :text => "yes", :question_id => @like_jam.id)
    @like_jam.answers << Factory(:answer, :text => "no", :question_id => @like_jam.id)
    # Dependency
    @what_is_wrong_with_you = Factory(:dependency, :rule => "A or B", :question_id => @what_is_wrong_with_you.id)
    @dep_a = Factory(:dependency_condition, :rule_key => "A", :question_id => @like_pie.id, :operator => "==", :answer_id => @like_pie.answers.first.id, :dependency_id => @what_is_wrong_with_you.id)
    @dep_b = Factory(:dependency_condition, :rule_key => "B", :question_id => @like_jam.id, :operator => "==", :answer_id => @like_jam.answers.first.id, :dependency_id => @what_is_wrong_with_you.id)
    # Responses
    @response_set = Factory(:response_set)
    @response_set.responses << Factory(:response, :question_id => @like_pie.id, :answer_id => @like_pie.answers.last.id, :response_set_id => @response_set.id)
  end
  it "should list all dependencies for answered questions" do
    dependency_conditions = @response_set.send(:dependencies).last.dependency_conditions
    dependency_conditions.size.should == 2
    dependency_conditions.should include(@dep_a)
    dependency_conditions.should include(@dep_b)

  end
  it "should list all dependencies for passed question_id" do
    # Questions
    like_ice_cream = Factory(:question, :text => "Do you like ice_cream?", :survey_section => @section)
    what_flavor = Factory(:question, :text => "What flavor?", :survey_section => @section)
    # Answers
    like_ice_cream.answers << Factory(:answer, :text => "yes", :question_id => like_ice_cream.id)
    like_ice_cream.answers << Factory(:answer, :text => "no", :question_id => like_ice_cream.id)
    what_flavor.answers << Factory(:answer, :response_class => :string, :question_id => what_flavor.id)
    # Dependency
    flavor_dependency = Factory(:dependency, :rule => "C", :question_id => what_flavor.id)
    flavor_dependency_condition = Factory(:dependency_condition, :rule_key => "A", :question_id => like_ice_cream.id, :operator => "==",
                                          :answer_id => like_ice_cream.answers.first.id, :dependency_id => flavor_dependency.id)
    # Responses
    dependency_conditions = @response_set.send(:dependencies, like_ice_cream.id).should == [flavor_dependency]
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
      @response_set.responses << Factory(:response, :response_set => @response_set, :question => dq, :answer => (triggered == "triggered" ? da : dx))
      @response_set.responses << Factory(:response, :response_set => @response_set, :question => q, :answer => a)
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
