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

  # this causes issues with building and saving
  # it "should be invalid without a answer_id" do
  #   @validation.answer_id = nil
  #   @validation.should have(1).error_on(:answer_id)
  # end

  it "should be invalid unless rule composed of only references and operators" do
    @validation.rule = "foo"
    @validation.should have(1).error_on(:rule)
    @validation.rule = "1 to 2"
    @validation.should have(1).error_on(:rule)
    @validation.rule = "a and b"
    @validation.should have(1).error_on(:rule)
  end
end
describe Validation, "reporting its status" do
  def test_var(vhash, vchashes, ahash, rhash)
    a = Factory(:answer, ahash)
    v = Factory(:validation, {:answer => a, :rule => "A"}.merge(vhash))
    vchashes.each do |vchash|
      Factory(:validation_condition, {:validation => v, :rule_key => "A"}.merge(vchash))
    end
    rs = Factory(:response_set)
    r = Factory(:response, {:answer => a, :question => a.question}.merge(rhash))
    rs.responses << r
    return v.is_valid?(rs)
  end

  it "should validate a response by integer comparison" do
    test_var({:rule => "A and B"}, [{:operator => ">=", :integer_value => 0}, {:rule_key => "B", :operator => "<=", :integer_value => 120}], {:response_class => "integer"}, {:integer_value => 48}).should be_true
  end
  it "should validate a response by regexp" do
    test_var({}, [{:operator => "=~", :regexp => /^[a-z]{1,6}$/}], {:response_class => "string"}, {:string_value => ""}).should be_false
  end
  it "should validate a response by (in)equality" do
    # test_var({:operator => "!=", :datetime_value => Date.today + 1}, {:response_class => "date"}, {:datetime_value => Date.today}).should be_true
    # test_var({:operator => "==", :answer_id => 2}, {:response_class => "answer"}, {:answer_id => 2}).should be_false
  end
  it "should validate a response by lookup" do
    
  end
end
