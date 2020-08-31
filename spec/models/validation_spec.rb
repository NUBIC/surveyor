require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Validation, type: :model do
  before(:each) do
    @validation = FactoryBot.create(:validation)
  end

  it "should be valid" do
    expect(@validation).to be_valid
  end

  it "should be invalid without a rule" do
    @validation.rule = nil
    expect(@validation).to have(2).errors_on(:rule)
    @validation.rule = " "
    expect(@validation).to have(1).errors_on(:rule)
  end

  # this causes issues with building and saving
  # it "should be invalid without a answer_id" do
  #   @validation.answer_id = nil
  #   @validation.should have(1).error_on(:answer_id)
  # end

  it "should be invalid unless rule composed of only references and operators" do
    @validation.rule = "foo"
    expect(@validation).to have(1).error_on(:rule)
    @validation.rule = "1 to 2"
    expect(@validation).to have(1).error_on(:rule)
    @validation.rule = "a and b"
    expect(@validation).to have(1).error_on(:rule)
  end
end
describe Validation, "reporting its status", type: :model do
  def test_var(vhash, vchashes, ahash, rhash)
    a = FactoryBot.create(:answer, ahash)
    v = FactoryBot.create(:validation, {:answer => a, :rule => "A"}.merge(vhash))
    vchashes.each do |vchash|
      FactoryBot.create(:validation_condition, {:validation => v, :rule_key => "A"}.merge(vchash))
    end
    rs = FactoryBot.create(:response_set)
    r = FactoryBot.create(:response, {:answer => a, :question => a.question}.merge(rhash))
    rs.responses << r
    return v.is_valid?(rs)
  end

  it "should validate a response by integer comparison" do
    expect(test_var({:rule => "A and B"}, [{:operator => ">=", :integer_value => 0}, {:rule_key => "B", :operator => "<=", :integer_value => 120}], {:response_class => "integer"}, {:integer_value => 48})).to be(true)
  end
  it "should validate a response by regexp" do
    expect(test_var({}, [{:operator => "=~", :regexp => '/^[a-z]{1,6}$/'}], {:response_class => "string"}, {:string_value => ""})).to be(false)
  end
end
describe Validation, "with conditions", type: :model do
  it "should destroy conditions when destroyed" do
    @validation = FactoryBot.create(:validation)
    FactoryBot.create(:validation_condition, :validation => @validation, :rule_key => "A")
    FactoryBot.create(:validation_condition, :validation => @validation, :rule_key => "B")
    FactoryBot.create(:validation_condition, :validation => @validation, :rule_key => "C")
    v_ids = @validation.validation_conditions.map(&:id)
    @validation.destroy
    v_ids.each{|id| expect(DependencyCondition.find_by_id(id)).to eq(nil)}
  end
end
