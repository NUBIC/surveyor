require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Validation do
  before(:each) do
    @validation = Factory(:validation)
  end
  
  it "should be valid" do
    @validation.should be_valid
  end
  
  it "should be invalid without a rule" do
    @validation.rule = nil
    @validation.should have(2).errors_on(:rule)
    @validation.rule = " "
    @validation.should have(1).errors_on(:rule)
  end

  it "should be invalid without a answer_id" do
    @validation.answer_id = nil
    @validation.should have(1).error_on(:answer_id)
  end

  it "should be invalid unless rule composed of only references and operators" do
    @validation.rule = "foo"
    @validation.should have(1).error_on(:rule)
    @validation.rule = "1 to 2"
    @validation.should have(1).error_on(:rule)
    @validation.rule = "a and b"
    @validation.should have(1).error_on(:rule)
  end
end
