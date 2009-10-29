require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'answer'

describe Answer, " when first created" do

  before do
    question = mock("Question", :id => 2, :parser => mock("Parser", :new_answer_id => 1))
    options = {:help_text => "Never or rarely ever", :reference_identifier => "b3a_1"}
    @ans = Answer.new(question, "No / Rarely", options)
  end
  
  it "should set inititalized variables to those passed in" do
    @ans.id.should == 1
    @ans.question_id.should == 2
    @ans.reference_identifier.should == "b3a_1"
    @ans.text.should == "No / Rarely"
    @ans.help_text.should == "Never or rarely ever"
    end
  
  it "should output current state to yml" do
     @ans.should.respond_to?(:to_yml)
  end

  it "should create a normalized code automatically when initalized" do
    @ans.data_export_identifier.should eql("no_rarely")
  end
  
end