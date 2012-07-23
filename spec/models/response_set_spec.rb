require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResponseSet do
  let(:response_set) { Factory(:response_set) }

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

  it "should protect api_id, timestamps, access_code, started_at, completed_at" do
    saved_attrs = @response_set.attributes
    if defined? ActiveModel::MassAssignmentSecurity::Error
      lambda {@response_set.update_attributes(:created_at => 3.days.ago, :updated_at => 3.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@response_set.update_attributes(:api_id => "NEW")}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@response_set.update_attributes(:access_code => "AND")}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@response_set.update_attributes(:started_at => 10.days.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@response_set.update_attributes(:completed_at => 2.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    else
      @response_set.attributes = {:created_at => 3.days.ago, :updated_at => 3.hours.ago} # automatically protected by Rails
      @response_set.attributes = {:api_id => "NEW"} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      @response_set.attributes = {:access_code => "AND"}
      @response_set.attributes = {:started_at => 10.days.ago}
      @response_set.attributes = {:completed_at => 2.hours.ago}
    end
    @response_set.attributes.should == saved_attrs
  end

  describe '#access_code' do
    let!(:rs1) { Factory(:response_set).tap { |rs| rs.update_attribute(:access_code, 'one') } }
    let!(:rs2) { Factory(:response_set).tap { |rs| rs.update_attribute(:access_code, 'two') } }

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

    it 'defaults to a random, non-conflicting value on init' do
      Surveyor::Common.should_receive(:make_tiny_code).and_return('one')
      Surveyor::Common.should_receive(:make_tiny_code).and_return('two')
      Surveyor::Common.should_receive(:make_tiny_code).and_return('three')

      ResponseSet.new.access_code.should == 'three'
    end
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
    # Rails 3.2 throws an ActiveModel::MassAssignmentSecurity::Error error on response_set.update_attribues
    # Using begin..rescue..end for Rails 3.1 and 3.0 backwards compatibility
    # lambda { @response_set.update_attributes(:completed_at => Time.now) }.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    begin
      @response_set.update_attributes(:completed_at => Time.now)
    rescue
    end
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

  it 'saves its responses' do
    new_set = ResponseSet.new(:survey => Factory(:survey))
    new_set.responses.build(:question_id => 1, :answer_id => 1, :string_value => 'XXL')
    new_set.save!

    ResponseSet.find(new_set.id).responses.should have(1).items
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

  describe '.to_savable' do
    let(:input)  { {} }
    let(:actual) { ResponseSet.to_savable(input) }

    it "should treat nil as empty" do
      ResponseSet.to_savable(nil).should == []
    end

    it 'should treat empty as empty' do
      actual.should == []
    end

    describe 'for a checkbox' do
      it 'ignores a new blank' do
        input["11"] = {"question_id" => "1", "answer_id" => [""]}
        actual.should == []
      end

      it 'saves a new answer' do
        input["12"] = {"question_id" => "2", "answer_id" => ["", "124"]}
        actual.should == [ {"question_id"=>"2", "answer_id"=>["", "124"]} ]
      end

      it 'deletes when updated to blank' do
        input["13"] = {"id" => "101", "question_id" => "3", "answer_id" => [""]}
        actual.should == [ {"question_id"=>"3", "id"=>"101", "_destroy"=>"1"} ]
      end

      it 'updates when updated' do
        input["14"] = {"id" => "102", "question_id" => "4", "answer_id" => ["", "147"]}
        actual.should == [ {"question_id"=>"4", "id"=>"102", "answer_id"=>["", "147"]} ]
      end
    end

    describe 'for a radio button' do
      it 'ignores a new blank' do
        input["15"] = {"question_id" => "5", "answer_id" => ""}
        actual.should == []
      end

      it 'saves a new answer' do
        input["16"] = {"question_id" => "6", "answer_id" => "161"}
        actual.should == [ {"question_id"=>"6", "answer_id"=>"161"} ]
      end

      it 'updates when updated' do
        input["17"] = {"id" => "103", "question_id" => "7", "answer_id" => "171"}
        actual.should == [ {"question_id"=>"7", "id"=>"103", "answer_id"=>"171"} ]
      end
    end

    describe 'for a string value' do
      it 'ignores a new blank' do
        input["19"] = {"question_id" => "9", "answer_id" => "191", "string_value" => ""}
        actual.should == []
      end

      it 'saves a new value' do
        input["20"] = {"question_id" => "10", "answer_id" => "201", "string_value" => "hi"}
        actual.should == [ {"question_id"=>"10", "string_value"=>"hi", "answer_id"=>"201"} ]
      end

      it 'updates when updated' do
        input["22"] = {"id" => "106", "question_id" => "12", "answer_id" => "221", "string_value" => "ho"}
        actual.should == [ {"question_id"=>"12", "id"=>"106", "string_value"=>"ho", "answer_id"=>"221"} ]
      end

      it 'destroys when cleared' do
        input['21'] = {"id" => "105", "question_id" => "11", "answer_id" => "211", "string_value" => ""}
        actual.should == [ {"question_id"=>"11", "string_value"=>"", "id"=>"105", "_destroy"=>"1"} ]
      end
    end

    describe 'for a checkbox plus string' do
      it 'ignores a new value that is not checked' do
        input["24"] = {"question_id" => "14", "answer_id" => [""], "string_value" => "foo"}
        actual.should == []
      end

      it 'saves a new value that is checked' do
        input["25"] = {"question_id" => "15", "answer_id" => ["", "241"], "string_value" => "bar"}
        actual.should == [ {"question_id"=>"15", "string_value"=>"bar", "answer_id"=>["", "241"]} ]
      end

      it 'ignores a new blank value that is checked' do
        input['25'] = {"question_id" => "15", "answer_id" => ["", "241"], "string_value" => ""}
        actual.should == []
      end

      it 'updates the value when updated and still checked' do
        input["27"] = {"id" => "109", "question_id" => "15", "answer_id" => ["", "251"], "string_value" => "mar"}
        actual.should == [ {"question_id"=>"15", "id"=>"109", "string_value"=>"mar", "answer_id"=>["", "251"]} ]
      end

      it 'deletes a blank value when still checked' do
        input["27"] = {"id" => "109", "question_id" => "15", "answer_id" => ["", "251"], "string_value" => ""}
        actual.should == [ {"question_id"=>"15", "id"=>"109", "_destroy" => '1', "string_value" => ""} ]
      end

      it 'destroys when unchecked' do
        input["26"] = {"id" => "108", "question_id" => "14", "answer_id" => [""], "string_value" => "moo"}
        actual.should == [ {"question_id"=>"14", "string_value"=>"moo", "id"=>"108", "_destroy"=>"1"} ]
      end
    end

    describe 'for a radio plus string' do
      it 'ignores a new value that is not checked' do
        input["28"] = {"question_id" => "16", "answer_id" => "", "string_value" => "foo"}
        actual.should == []
      end

      it 'saves a new value that is checked' do
        input["29"] = {"question_id" => "17", "answer_id" => "261", "string_value" => "bar"}
        actual.should == [ {"question_id"=>"17", "string_value"=>"bar", "answer_id"=>"261"} ]
      end

      it 'ignores a new blank value that is checked' do
        input["29"] = {"question_id" => "17", "answer_id" => "261", "string_value" => ""}
        actual.should == []
      end

      it 'updates the value when updated and still checked' do
        input["30"] = {"id" => "110", "question_id" => "18", "answer_id" => "271", "string_value" => "moo"}
        actual.should == [ {"question_id"=>"18", "id"=>"110", "string_value"=>"moo", "answer_id"=>"271"} ]
      end

      it 'deletes a blank value when still checked' do
        input["30"] = {"id" => "110", "question_id" => "18", "answer_id" => "271", "string_value" => ""}
        actual.should == [ {"question_id"=>"18", "id"=>"110", "_destroy"=>"1", "string_value" => ""} ]
      end
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
  end

  describe '.trim_for_lookups' do
    let(:input)  { {} }
    let(:actual) { ResponseSet.trim_for_lookups(input) }

    it 'leaves a simple pick=>one question and answer alone' do
      input['1'] = { "question_id" => "2", "answer_id" => "1" }
      actual['1'].should == { "question_id" => "2", "answer_id" => "1" }
    end

    it 'leaves a simple pick=>any question and answers alone' do
      input['2'] = { "question_id" => "3", "answer_id" => ["", "6"] }
      actual['2'].should == { "question_id" => "3", "answer_id" => ["", "6"] }
    end

    it 'ignores single values that are set' do
      input['9'] = { "question_id" => "6", "string_value" => "jack", "answer_id" => "13" }
      actual['9'].should == { "question_id" => "6", "answer_id" => "13" }
    end

    it 'ignores datetime component values that are set' do
      input['17'] = {
        "question_id"=>"13",
        "datetime_value(1i)"=>"2006",
        "datetime_value(2i)"=>"2",
        "datetime_value(3i)"=>"4",
        "datetime_value(4i)"=>"02",
        "datetime_value(5i)"=>"05",
        "answer_id"=>"21"
      }
      actual['17'].should == { 'question_id' => '13', 'answer_id' => '21' }
    end

    it 'converts blank values to destroy hints' do
      input['19'] = { "question_id" => "15", "datetime_value" => "", "answer_id" => "23", "id" => "1" }
      actual['19'].should == { 'question_id' => '15', 'answer_id' => '23', 'id' => '1', '_destroy' => 'true' }
    end

    it 'preserves incoming ids' do
      input['47'] = { "question_id" => "38", "answer_id" => "220", "integer_value" => "2", "id" => "2" }
      actual['47'].should == { "question_id" => "38", "answer_id" => "220", "id" => "2"}
    end

    it 'preserves incoming response_groups' do
      input['61'] = { "question_id" => "44", "response_group" => "0", "answer_id" => "241", "integer_value" => "12" }
      actual['61'].should == { "question_id" => "44", "response_group" => "0", "answer_id" => "241" }
    end
  end

  it "should remove responses" do
    r = @response_set.responses.create(:question_id => 1, :answer_id => 2)
    r.id.should_not be nil
    @response_set.should have(1).responses
    ResponseSet.to_savable({"2"=>{"question_id"=>"1", "id"=> r.id, "answer_id"=>[""]}}).should == [{"question_id"=>"1", "id"=> r.id, "_destroy"=> "1" }]
    @response_set.update_attributes(:responses_attributes => [{"question_id"=>"1", "id"=> r.id, "_destroy"=> "1"}]).should be_true
    @response_set.reload.should have(0).responses
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
        ['string_value',   'foo',           '', 'foo'],
        ['datetime_value', '2010-10-01',    '', Date.new(2010, 10, 1)],
        ['integer_value',  '9',             '', 9],
        ['float_value',    '4.0',           '', 4.0],
        ['text_value',     'more than foo', '', 'more than foo']
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

    it 'rolls back all changes on failure' do
      ui_hash['0'] = ui_response('question_id' => '42', 'answer_id' => answer_id.to_s)
      ui_hash['1'] = { 'answer_id' => '7' }

      begin
        do_ui_update
      rescue
      end

      response_set.reload.responses.should be_empty
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
      q.correct_answer = (quiz == "quiz" ? a : nil)
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

describe ResponseSet, "#as_json" do
  let(:rs) {
    Factory(:response_set, :responses => [
          Factory(:response, :question => Factory(:question), :answer => Factory(:answer), :string_value => '2')])
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
