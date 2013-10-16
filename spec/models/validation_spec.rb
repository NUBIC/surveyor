require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Validation do
  before(:each) do
    @validation = FactoryGirl.create(:validation)
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
    a = FactoryGirl.create(:answer, ahash)
    v = FactoryGirl.create(:validation, {:answer => a, :rule => "A"}.merge(vhash))
    vchashes.each do |vchash|
      FactoryGirl.create(:validation_condition, {:validation => v, :rule_key => "A"}.merge(vchash))
    end
    rs = FactoryGirl.create(:response_set)
    r = FactoryGirl.create(:response, {:answer => a, :question => a.question}.merge(rhash))
    rs.responses << r
    return v.is_valid?(rs)
  end

  it "should validate a response by integer comparison" do
    test_var({:rule => "A and B"}, [{:operator => ">=", :integer_value => 0}, {:rule_key => "B", :operator => "<=", :integer_value => 120}], {:response_class => "integer"}, {:integer_value => 48}).should be_true
  end
  it "should validate a response by regexp" do
    test_var({}, [{:operator => "=~", :regexp => '/^[a-z]{1,6}$/'}], {:response_class => "string"}, {:string_value => ""}).should be_false
  end
end
describe Validation, "with conditions" do
  it "should destroy conditions when destroyed" do
    @validation = FactoryGirl.create(:validation)
    FactoryGirl.create(:validation_condition, :validation => @validation, :rule_key => "A")
    FactoryGirl.create(:validation_condition, :validation => @validation, :rule_key => "B")
    FactoryGirl.create(:validation_condition, :validation => @validation, :rule_key => "C")
    v_ids = @validation.validation_conditions.map(&:id)
    @validation.destroy
    v_ids.each{|id| DependencyCondition.find_by_id(id).should == nil}
  end
end