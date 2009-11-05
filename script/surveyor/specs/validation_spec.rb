require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'validation'

describe Validation, " when first created" do
  before do    
    answer = mock("Answer", :id => 2, :parser => mock("Parser", :new_validation_id => 1))
    answer.stub!(:class => Answer)
    args = [{:rule => "C", :message => "Please select a number between 0 and 120"}]
    options = {}
    @validation = Validation.new(answer, args, options)
  end
  
  it "should set initialization parameters properly" do
    @validation.id.should == 1
    @validation.message.should == "Please select a number between 0 and 120"
    @validation.answer_id.should == 2
    @validation.rule.should == "C"
  end

  it "should output current state to yml" do
  end

end