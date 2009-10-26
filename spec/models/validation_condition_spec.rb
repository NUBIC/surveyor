require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ValidationCondition, "Class methods" do
  it "should have a list of operators" do
    %w(== != < > <= >= =~).each{|operator| ValidationCondition.operators.include?(operator).should be_true }
  end
end

describe ValidationCondition do
  before(:each) do
    @validation_condition = Factory(:validation_condition)
  end
  
  it "should be valid" do
     @validation_condition.should be_valid
  end
  
  it "should be invalid without a parent validation_id" do
    @validation_condition.validation_id = nil
    @validation_condition.should have(1).errors_on(:validation_id)
  end

  it "should be invalid without an operator" do
    @validation_condition.operator = nil
    @validation_condition.should have(2).errors_on(:operator)
  end
  
  it "should be invalid without a rule_key" do
    @validation_condition.should be_valid
    @validation_condition.rule_key = nil
    @validation_condition.should_not be_valid
    @validation_condition.should have(1).errors_on(:rule_key)
  end

  it "should have unique rule_key within the context of a validation" do
   @validation_condition.should be_valid
   Factory(:validation_condition, :validation_id => 2, :rule_key => "2")
   @validation_condition.rule_key = "2" #rule key uniquness is scoped by validation_id
   @validation_condition.validation_id = 2
   @validation_condition.should_not be_valid
   @validation_condition.should have(1).errors_on(:rule_key)
  end

  it "should have an operator in ValidationCondition.operators" do
    ValidationCondition.operators.each do |o|
      @validation_condition.operator = o
      @validation_condition.should have(0).errors_on(:operator)
    end
    @validation_condition.operator = "#"
    @validation_condition.should have(1).error_on(:operator)
  end
  
end

describe ValidationCondition, "validating responses" do
  def test_var(vhash, ahash, rhash)
    v = Factory(:validation_condition, vhash)
    a = Factory(:answer, ahash)
    r = Factory(:response, rhash.merge(:answer => a, :question => a.question))
    return v.is_valid?(r)
  end
  
  it "should validate a response by regexp" do
    test_var({:operator => "=~", :regexp => /^[a-z]{1,6}$/}, {:response_class => "string"}, {:string_value => "clear"}).should be_true
    test_var({:operator => "=~", :regexp => /^[a-z]{1,6}$/}, {:response_class => "string"}, {:string_value => "foobarbaz"}).should be_false
  end
  it "should validate a response by integer comparison" do
    test_var({:operator => ">", :integer_value => 3}, {:response_class => "integer"}, {:integer_value => 4}).should be_true
    test_var({:operator => "<=", :integer_value => 256}, {:response_class => "integer"}, {:integer_value => 512}).should be_false
  end
  it "should validate a response by (in)equality" do
    test_var({:operator => "!=", :datetime_value => Date.today + 1}, {:response_class => "date"}, {:datetime_value => Date.today}).should be_true
    test_var({:operator => "==", :answer_id => 2}, {:response_class => "answer"}, {:answer_id => 2}).should be_false
  end
  it "should represent itself as a hash" do
    @v = Factory(:validation_condition, :rule_key => "A")
    @v.stub!(:is_valid?).and_return(true)
    @v.to_hash("foo").should == {:A => true}
    @v.stub!(:is_valid?).and_return(false)
    @v.to_hash("foo").should == {:A => false}
  end
end