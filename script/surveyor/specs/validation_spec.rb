require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'validation'

describe SurveyParser::Validation, " when first created" do
  before do    
    answer = mock("SurveyParser::Answer", :id => 2, :parser => mock("SurveyParser::Parser", :new_validation_id => 1))
    answer.stub!(:class => SurveyParser::Answer)
    args = [{:rule => "C", :message => "Please select a number between 0 and 120"}]
    options = {}
    @validation = SurveyParser::Validation.new(answer, args, options)
  end
  
  it "should set initialization parameters properly" do
    @validation.id.should == 1
    @validation.message.should == "Please select a number between 0 and 120"
    @validation.answer_id.should == 2
    @validation.rule.should == "C"
  end

end