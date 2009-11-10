require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'validation_condition'

describe SurveyParser::ValidationCondition, " when first created" do
  before do    
    validation = mock("SurveyParser::Validation", :id => 29, :parser => mock("SurveyParser::Parser", :new_validation_condition_id => 21))
    validation.stub!(:class => SurveyParser::Validation)
    args = [">=", {:integer_value => 0}]
    options = {}
    @validation_condition = SurveyParser::ValidationCondition.new(validation, args, options)
  end
  
  it "should set initialization parameters properly" do
    @validation_condition.id.should == 21
    @validation_condition.validation_id.should == 29
    @validation_condition.integer_value.should == 0
    @validation_condition.operator.should == ">="
  end

end