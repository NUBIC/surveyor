require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResponseSet do
  let(:response_set) { FactoryGirl.create(:response_set) }

  before(:each) do
    @response_set = FactoryGirl.create(:response_set)
    @radio_response_attributes = HashWithIndifferentAccess.new({"1"=>{"question_id"=>"1", "answer_id"=>"1", "string_value"=>"XXL"}, "2"=>{"question_id"=>"2", "answer_id"=>"6"}, "3"=>{"question_id"=>"3"}})
    @checkbox_response_attributes = HashWithIndifferentAccess.new({"1"=>{"question_id"=>"9", "answer_id"=>"11"}, "2"=>{"question_id"=>"9", "answer_id"=>"12"}})
    @other_response_attributes = HashWithIndifferentAccess.new({"6"=>{"question_id"=>"6", "answer_id" => "3", "string_value"=>""}, "7"=>{"question_id"=>"7", "answer_id" => "4", "text_value"=>"Brian is tired"}, "5"=>{"question_id"=>"5", "answer_id" => "5", "string_value"=>""}})
  end

  it "should have a unique code with length 10 that identifies the survey" do
    @response_set.access_code.should_not be_nil
    @response_set.access_code.length.should == 10
  end

  describe '#access_code' do
    let!(:rs1) { FactoryGirl.create(:response_set).tap { |rs| rs.update_attribute(:access_code, 'one') } }
    let!(:rs2) { FactoryGirl.create(:response_set).tap { |rs| rs.update_attribute(:access_code, 'two') } }

    # Regression test for #263
    it 'accepts an access code in the constructor' do
      rs = ResponseSet.new
      rs.access_code = 'eleven'
      rs.access_code.should == 'eleven'
    end

    # Regression test for #263
    it 'setter accepts a conflicting access code' do
      rs2.access_code = 'one'
      rs2.access_code.should == 'one'
    end

    it 'is invalid when conflicting' do
      rs2.access_code = 'one'
      rs2.should_not be_valid
      rs2.should have(1).errors_on(:access_code)
    end
  end

  it "is completable" do
    @response_set.completed_at.should be_nil
    @response_set.complete!
    @response_set.completed_at.should_not be_nil
    @response_set.completed_at.is_a?(Time).should be_true
    @response_set.should be_complete
  end

  it 'saves its responses' do
    new_set = ResponseSet.new(:survey => FactoryGirl.create(:survey))
    new_set.responses.build(:question_id => 1, :answer_id => 1, :string_value => 'XXL')
    new_set.save!

    ResponseSet.find(new_set.id).responses.should have(1).items
  end

  describe '#update_from_ui_hash' do
    let(:ui_hash) { {} }
    let(:api_id)  { 'ABCDEF-1234-567890' }

    let(:question_id) { 42 }
    let(:answer_id) { 137 }

    def ui_response(attrs={})
      { 'question_id' => question_id.to_s, 'api_id' => api_id }.merge(attrs)
    end

    def do_ui_update
      response_set.update_from_ui_hash(ui_hash)
    end

    def resulting_response
      # response_set_id criterion is to make sure a created response is
      # appropriately associated.
      Response.where(:api_id => api_id, :response_set_id => response_set).first
    end

    shared_examples 'pick one or any' do
      it 'saves an answer alone' do
        ui_hash['3'] = ui_response('answer_id' => set_answer_id)
        do_ui_update
        resulting_response.answer_id.should == answer_id
      end

      it 'preserves the question' do
        ui_hash['4'] = ui_response('answer_id' => set_answer_id)
        do_ui_update
        resulting_response.question_id.should == question_id
      end

      it 'interprets a blank answer as no response' do
        ui_hash['7'] = ui_response('answer_id' => blank_answer_id)
        do_ui_update
        resulting_response.should be_nil
      end

      it 'interprets no answer_id as no response' do
        ui_hash['8'] = ui_response
        do_ui_update
        resulting_response.should be_nil
      end

      [
        ['string_value',   'foo',              '', 'foo'],
        ['datetime_value', '2010-10-01 17:15', '', Time.zone.parse('2010-10-1 17:15')],
        ['date_value',     '2010-10-01',       '', '2010-10-01'],
        ['time_value',     '17:15',            '', '17:15'],
        ['integer_value',  '9',                '', 9],
        ['float_value',    '4.0',              '', 4.0],
        ['text_value',     'more than foo',    '', 'more than foo']
      ].each do |value_type, set_value, blank_value, expected_value|
        describe "plus #{value_type}" do
          it 'saves the value' do
            ui_hash['11'] = ui_response('answer_id' => set_answer_id, value_type => set_value)
            do_ui_update
            resulting_response.send(value_type).should == expected_value
          end

          it 'interprets a blank answer as no response' do
            ui_hash['18'] = ui_response('answer_id' => blank_answer_id, value_type => set_value)
            do_ui_update
            resulting_response.should be_nil
          end

          it 'interprets a blank value as no response' do
            ui_hash['29'] = ui_response('answer_id' => set_answer_id, value_type => blank_value)
            do_ui_update
            resulting_response.should be_nil
          end

          it 'interprets no answer_id as no response' do
            ui_hash['8'] = ui_response(value_type => set_value)
            do_ui_update
            resulting_response.should be_nil
          end
        end
      end
    end

    shared_examples 'response interpretation' do
      it 'fails when api_id is not provided' do
        ui_hash['0'] = { 'question_id' => question_id }
        lambda { do_ui_update }.should raise_error(/api_id missing from response 0/)
      end

      describe 'for a radio button' do
        let(:set_answer_id)   { answer_id.to_s }
        let(:blank_answer_id) { '' }

        include_examples 'pick one or any'
      end

      describe 'for a checkbox' do
        let(:set_answer_id)   { ['', answer_id.to_s] }
        let(:blank_answer_id) { [''] }

        include_examples 'pick one or any'
      end
    end

    describe 'with a new response' do
      include_examples 'response interpretation'

      # After much effort I cannot produce this situation in a test, either with
      # with threads or separate processes. While SQLite 3 will nominally allow
      # for some coarse-grained concurrency, it does not appear to work with
      # simultaneous write transactions the way AR uses SQLite. Instead,
      # simultaneous write transactions always result in a
      # SQLite3::BusyException, regardless of the connection's timeout setting.
      it 'fails predicably when another response with the same api_id is created in a simultaneous open transaction'
    end

    describe 'with an existing response' do
      let!(:original_response) {
        response_set.responses.build(:question_id => question_id, :answer_id => answer_id).tap do |r|
          r.api_id = api_id # not mass assignable
          r.save!
        end
      }

      include_examples 'response interpretation'

      it 'fails when the existing response is for a different question' do
        ui_hash['76'] = ui_response('question_id' => '43', 'answer_id' => answer_id.to_s)

        lambda { do_ui_update }.should raise_error(/Illegal attempt to change question for response #{api_id}./)
      end
    end

    # clean_with_truncation is necessary because AR 3.0 can't roll back a nested
    # transaction with SQLite.
    it 'rolls back all changes on failure', :clean_with_truncation do
      ui_hash['0'] = ui_response('question_id' => '42', 'answer_id' => answer_id.to_s)
      ui_hash['1'] = { 'answer_id' => '7' } # no api_id

      begin
        do_ui_update
        fail "Expected error did not occur"
      rescue
      end

      response_set.reload.responses.should be_empty
    end
  end
end

describe ResponseSet, "with dependencies" do
  before(:each) do
    @section = FactoryGirl.create(:survey_section)
    # Questions
    @do_you_like_pie = FactoryGirl.create(:question, :text => "Do you like pie?", :survey_section => @section)
    @what_flavor = FactoryGirl.create(:question, :text => "What flavor?", :survey_section => @section)
    @what_bakery = FactoryGirl.create(:question, :text => "What bakery?", :survey_section => @section)
    # Answers
    @do_you_like_pie.answers << FactoryGirl.create(:answer, :text => "yes", :question_id => @do_you_like_pie.id)
    @do_you_like_pie.answers << FactoryGirl.create(:answer, :text => "no", :question_id => @do_you_like_pie.id)
    @what_flavor.answers << FactoryGirl.create(:answer, :response_class => :string, :question_id => @what_flavor.id)
    @what_bakery.answers << FactoryGirl.create(:answer, :response_class => :string, :question_id => @what_bakery.id)
    # Dependency
    @what_flavor_dep = FactoryGirl.create(:dependency, :rule => "A", :question_id => @what_flavor.id)
    FactoryGirl.create(:dependency_condition, :rule_key => "A", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_flavor_dep.id)
    @what_bakery_dep = FactoryGirl.create(:dependency, :rule => "B", :question_id => @what_bakery.id)
    FactoryGirl.create(:dependency_condition, :rule_key => "B", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_bakery_dep.id)
    # Responses
    @response_set = FactoryGirl.create(:response_set)
    @response_set.responses << FactoryGirl.create(:response, :question_id => @do_you_like_pie.id, :answer_id => @do_you_like_pie.answers.first.id, :response_set_id => @response_set.id)
    @response_set.responses << FactoryGirl.create(:response, :string_value => "pecan pie", :question_id => @what_flavor.id, :answer_id => @what_flavor.answers.first.id, :response_set_id => @response_set.id)
  end

  it "should list unanswered dependencies to show at the top of the next page (javascript turned off)" do
    @response_set.unanswered_dependencies.should == [@what_bakery]
  end
  it "should list answered and unanswered dependencies to show inline (javascript turned on)" do
    @response_set.all_dependencies[:show].should == ["q_#{@what_flavor.id}", "q_#{@what_bakery.id}"]
  end
  it "should list group as dependency" do
    # Question Group
    crust_group = FactoryGirl.create(:question_group, :text => "Favorite Crusts")

    # Question
    what_crust = FactoryGirl.create(:question, :text => "What is your favorite curst type?", :survey_section => @section)
    crust_group.questions << what_crust

    # Answers
    what_crust.answers << FactoryGirl.create(:answer, :response_class => :string, :question_id => what_crust.id)

    # Dependency
    crust_group_dep = FactoryGirl.create(:dependency, :rule => "C", :question_group_id => crust_group.id, :question => nil)
    FactoryGirl.create(:dependency_condition, :rule_key => "C", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => crust_group_dep.id)

    @response_set.unanswered_dependencies.should == [@what_bakery, crust_group]
  end
end
describe ResponseSet, "dependency_conditions" do
  before do
    @section = FactoryGirl.create(:survey_section)
    # Questions
    @like_pie = FactoryGirl.create(:question, :text => "Do you like pie?", :survey_section => @section)
    @like_jam = FactoryGirl.create(:question, :text => "Do you like jam?", :survey_section => @section)
    @what_is_wrong_with_you = FactoryGirl.create(:question, :text => "What's wrong with you?", :survey_section => @section)
    # Answers
    @like_pie.answers << FactoryGirl.create(:answer, :text => "yes", :question_id => @like_pie.id)
    @like_pie.answers << FactoryGirl.create(:answer, :text => "no", :question_id => @like_pie.id)
    @like_jam.answers << FactoryGirl.create(:answer, :text => "yes", :question_id => @like_jam.id)
    @like_jam.answers << FactoryGirl.create(:answer, :text => "no", :question_id => @like_jam.id)
    # Dependency
    @what_is_wrong_with_you = FactoryGirl.create(:dependency, :rule => "A or B", :question_id => @what_is_wrong_with_you.id)
    @dep_a = FactoryGirl.create(:dependency_condition, :rule_key => "A", :question_id => @like_pie.id, :operator => "==", :answer_id => @like_pie.answers.first.id, :dependency_id => @what_is_wrong_with_you.id)
    @dep_b = FactoryGirl.create(:dependency_condition, :rule_key => "B", :question_id => @like_jam.id, :operator => "==", :answer_id => @like_jam.answers.first.id, :dependency_id => @what_is_wrong_with_you.id)
    # Responses
    @response_set = FactoryGirl.create(:response_set)
    @response_set.responses << FactoryGirl.create(:response, :question_id => @like_pie.id, :answer_id => @like_pie.answers.last.id, :response_set_id => @response_set.id)
  end
  it "should list all dependencies for answered questions" do
    dependency_conditions = @response_set.send(:dependencies).last.dependency_conditions
    dependency_conditions.size.should == 2
    dependency_conditions.should include(@dep_a)
    dependency_conditions.should include(@dep_b)

  end
  it "should list all dependencies for passed question_id" do
    # Questions
    like_ice_cream = FactoryGirl.create(:question, :text => "Do you like ice_cream?", :survey_section => @section)
    what_flavor = FactoryGirl.create(:question, :text => "What flavor?", :survey_section => @section)
    # Answers
    like_ice_cream.answers << FactoryGirl.create(:answer, :text => "yes", :question_id => like_ice_cream.id)
    like_ice_cream.answers << FactoryGirl.create(:answer, :text => "no", :question_id => like_ice_cream.id)
    what_flavor.answers << FactoryGirl.create(:answer, :response_class => :string, :question_id => what_flavor.id)
    # Dependency
    flavor_dependency = FactoryGirl.create(:dependency, :rule => "C", :question_id => what_flavor.id)
    flavor_dependency_condition = FactoryGirl.create(:dependency_condition, :rule_key => "A", :question_id => like_ice_cream.id, :operator => "==",
                                          :answer_id => like_ice_cream.answers.first.id, :dependency_id => flavor_dependency.id)
    # Responses
    dependency_conditions = @response_set.send(:dependencies, like_ice_cream.id).should == [flavor_dependency]
  end
end

describe ResponseSet, "as a quiz" do
  before(:each) do
    @survey = FactoryGirl.create(:survey)
    @section = FactoryGirl.create(:survey_section, :survey => @survey)
    @response_set = FactoryGirl.create(:response_set, :survey => @survey)
  end
  def generate_responses(count, quiz = nil, correct = nil)
    count.times do |i|
      q = FactoryGirl.create(:question, :survey_section => @section)
      a = FactoryGirl.create(:answer, :question => q, :response_class => "answer")
      x = FactoryGirl.create(:answer, :question => q, :response_class => "answer")
      q.correct_answer = (quiz == "quiz" ? a : nil)
      @response_set.responses << FactoryGirl.create(:response, :question => q, :answer => (correct == "correct" ? a : x))
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
    @survey = FactoryGirl.create(:survey)
    @section = FactoryGirl.create(:survey_section, :survey => @survey)
    @response_set = FactoryGirl.create(:response_set, :survey => @survey)
  end
  def generate_responses(count, mandatory = nil, responded = nil)
    count.times do |i|
      q = FactoryGirl.create(:question, :survey_section => @section, :is_mandatory => (mandatory == "mandatory"))
      a = FactoryGirl.create(:answer, :question => q, :response_class => "answer")
      if responded == "responded"
        @response_set.responses << FactoryGirl.create(:response, :question => q, :answer => a)
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
    FactoryGirl.create(:question, :survey_section => @section, :display_type => "label", :is_mandatory => true)
    FactoryGirl.create(:question, :survey_section => @section, :display_type => "image", :is_mandatory => true)
    @response_set.mandatory_questions_complete?.should be_true
    @response_set.progress_hash.should == {:questions => 5, :triggered => 5, :triggered_mandatory => 5, :triggered_mandatory_completed => 5}
  end
end
describe ResponseSet, "with mandatory, dependent questions" do
  before(:each) do
    @survey = FactoryGirl.create(:survey)
    @section = FactoryGirl.create(:survey_section, :survey => @survey)
    @response_set = FactoryGirl.create(:response_set, :survey => @survey)
  end
  def generate_responses(count, mandatory = nil, dependent = nil, triggered = nil)
    dq = FactoryGirl.create(:question, :survey_section => @section, :is_mandatory => (mandatory == "mandatory"))
    da = FactoryGirl.create(:answer, :question => dq, :response_class => "answer")
    dx = FactoryGirl.create(:answer, :question => dq, :response_class => "answer")
    count.times do |i|
      q = FactoryGirl.create(:question, :survey_section => @section, :is_mandatory => (mandatory == "mandatory"))
      a = FactoryGirl.create(:answer, :question => q, :response_class => "answer")
      if dependent == "dependent"
        d = FactoryGirl.create(:dependency, :question => q)
        dc = FactoryGirl.create(:dependency_condition, :dependency => d, :question_id => dq.id, :answer_id => da.id)
      end
      @response_set.responses << FactoryGirl.create(:response, :response_set => @response_set, :question => dq, :answer => (triggered == "triggered" ? da : dx))
      @response_set.responses << FactoryGirl.create(:response, :response_set => @response_set, :question => q, :answer => a)
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
    @section = FactoryGirl.create(:survey_section)
    # Questions
    @do_you_like_pie = FactoryGirl.create(:question, :text => "Do you like pie?", :survey_section => @section)
    @what_flavor = FactoryGirl.create(:question, :text => "What flavor?", :survey_section => @section)
    @what_bakery = FactoryGirl.create(:question, :text => "What bakery?", :survey_section => @section)
    # Answers
    @do_you_like_pie.answers << FactoryGirl.create(:answer, :text => "yes", :question_id => @do_you_like_pie.id)
    @do_you_like_pie.answers << FactoryGirl.create(:answer, :text => "no", :question_id => @do_you_like_pie.id)
    @what_flavor.answers << FactoryGirl.create(:answer, :response_class => :string, :question_id => @what_flavor.id)
    @what_bakery.answers << FactoryGirl.create(:answer, :response_class => :string, :question_id => @what_bakery.id)
    # Responses
    @response_set = FactoryGirl.create(:response_set)
    @response_set.responses << FactoryGirl.create(:response, :question_id => @do_you_like_pie.id, :answer_id => @do_you_like_pie.answers.first.id, :response_set_id => @response_set.id)
    @response_set.responses << FactoryGirl.create(:response, :string_value => "pecan pie", :question_id => @what_flavor.id, :answer_id => @what_flavor.answers.first.id, :response_set_id => @response_set.id)
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

describe ResponseSet, "#as_json" do
  let(:rs) {
    FactoryGirl.create(:response_set, :responses => [
          FactoryGirl.create(:response, :question => FactoryGirl.create(:question), :answer => FactoryGirl.create(:answer), :string_value => '2')])
  }

  let(:js) {rs.as_json}

  it "should include uuid, survey_id" do
    js[:uuid].should == rs.api_id
  end

  it "should include responses with uuid, question_id, answer_id, value" do
    r0 = rs.responses[0]
    js[:responses][0][:uuid].should == r0.api_id
    js[:responses][0][:answer_id].should == r0.answer.api_id
    js[:responses][0][:question_id].should == r0.question.api_id
    js[:responses][0][:value].should == r0.string_value
  end
end
