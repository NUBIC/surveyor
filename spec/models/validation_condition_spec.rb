require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ValidationCondition do
  before(:each) do
    @validation_condition = Factory(:validation_condition)
  end
  
  it "should be valid" do
     @validation_condition.should be_valid
  end
end
