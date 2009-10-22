require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Validation do
  before(:each) do
    @validation = Factory(:validation)
  end
  
  it "should be valid" do
    @validation.should be_valid
  end
end
