require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'question'

describe Question, " when first created" do
  before do    
    section = mock("SurveySection", :id => 2, :parser => mock("Parser", :new_question_id => 1))
    args = {:help_text => "Please give a rough estimate", :reference_identifier => "B3"}
    options = {}
    @ques = Question.new(section, ["In the past 12 months how many times have you been to a doctor?", args], options)
  end
  
  it "should set initialization parameters properly" do
    @ques.id.should == 1
    @ques.reference_identifier.should == "B3"
    @ques.survey_section_id.should == 2
    @ques.help_text.should == "Please give a rough estimate"
    
    #Checking the defaults
    @ques.pick.should == :none
    @ques.display_type.should == :default
    @ques.is_mandatory.should == true
  end

  it "should output current state to yml" do
     @ques.should.respond_to?(:to_yml)
  end

  it "should create a normalized code automatically when initalized" do
    @ques.data_export_identifier.should eql("many_times_you_been_doctor")
  end
  
  # We don't change titles via the DSL
  # it "should update the normalized code if the title is changed" do
  #   @ques.data_export_identifier.should == "many_times_you_been_doctor"
  #   @ques.text = "Sometimes or All the time?"
  #   @ques.data_export_identifier.should == "sometimes_all_time"
  # end

end

describe Question, "when it contains data" do
  before(:each) do
    section = mock("SurveySection", :id => 2, :parser => mock("Parser", :new_question_id => 1))
    args = {:help_text => "Please give a rough estimate", :reference_identifier => "B3"}
    options = {}
    @ques = Question.new(section, ["In the past 12 months how many times have you been to a doctor?", args], options)
    @ques.answers << mock("Answer", :reference_identifier => "1", :text => "foo")
    @ques.answers << mock("Answer", :reference_identifier => "2", :text => "foo")
    @ques.answers << mock("Answer", :reference_identifier => "3", :text => "foo")
  end

  it "should have added the test answers correctly" do
    @ques.answers.length.should eql(3)
  end
  
  it "should find an answer by reference" do
    a_to_find = @ques.find_answer_by_reference("2")
    a_to_find.should_not be_nil
    a_to_find.reference_identifier.should eql("2")
  end
  
end
