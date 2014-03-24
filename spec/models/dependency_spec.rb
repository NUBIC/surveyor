require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dependency do
  before(:each) do
    @dependency = FactoryGirl.create(:dependency)
  end

  it "should be valid" do
    @dependency.should be_valid
  end

  it "should be invalid without a rule" do
    @dependency.rule = nil
    @dependency.should have(2).errors_on(:rule)
    @dependency.rule = " "
    @dependency.should have(1).errors_on(:rule)
  end

  it "should be invalid without a question_id" do
    @dependency.question_id = nil
    @dependency.should have(1).error_on(:question_id)

    @dependency.question_group_id = 1
    @dependency.should be_valid

    @dependency.question_id.should be_nil
    @dependency.question_group_id = nil
    @dependency.should have(1).error_on(:question_group_id)
  end

  it "should alias question_id as dependent_question_id" do
    @dependency.question_id = 19
    @dependency.dependent_question_id.should == 19
    @dependency.dependent_question_id = 14
    @dependency.question_id.should == 14
  end

  it "should be invalid unless rule composed of only references and operators" do
    @dependency.rule = "foo"
    @dependency.should have(1).error_on(:rule)
    @dependency.rule = "1 to 2"
    @dependency.should have(1).error_on(:rule)
    @dependency.rule = "a and b"
    @dependency.should have(1).error_on(:rule)
  end
end

describe Dependency, "when evaluating dependency conditions of a question in a response set" do

  before(:each) do
    @dep = Dependency.new(:rule => "A", :question_id => 1)
    @dep2 = Dependency.new(:rule => "A and B", :question_id => 1)
    @dep3 = Dependency.new(:rule => "A or B", :question_id => 1)
    @dep4 = Dependency.new(:rule => "!(A and B) and C", :question_id => 1)
    
    @dep_c = mock_model(DependencyCondition, :id => 1, :rule_key => "A", :to_hash => {:A => true})
    @dep_c2 = mock_model(DependencyCondition, :id => 2, :rule_key => "B", :to_hash => {:B => false})
    @dep_c3 = mock_model(DependencyCondition, :id => 3, :rule_key => "C", :to_hash => {:C => true})

    @dep.stub(:dependency_conditions).and_return([@dep_c])
    @dep2.stub(:dependency_conditions).and_return([@dep_c, @dep_c2])
    @dep3.stub(:dependency_conditions).and_return([@dep_c, @dep_c2])
    @dep4.stub(:dependency_conditions).and_return([@dep_c, @dep_c2, @dep_c3])
  end

  it "knows if the dependencies are met" do
    @dep.is_met?(@response_set).should be_true
    @dep2.is_met?(@response_set).should be_false
    @dep3.is_met?(@response_set).should be_true
    @dep4.is_met?(@response_set).should be_true
  end

  it "returns the proper keyed pairs from the dependency conditions" do
    @dep.conditions_hash(@response_set).should == {:A => true}
    @dep2.conditions_hash(@response_set).should == {:A => true, :B => false}
    @dep3.conditions_hash(@response_set).should == {:A => true, :B => false}
    @dep4.conditions_hash(@response_set).should == {:A => true, :B => false, :C => true}
  end
end
describe Dependency, "with conditions" do
  it "should destroy conditions when destroyed" do
    @dependency = Dependency.new(:rule => "A and B and C", :question_id => 1)
    FactoryGirl.create(:dependency_condition, :dependency => @dependency, :rule_key => "A")
    FactoryGirl.create(:dependency_condition, :dependency => @dependency, :rule_key => "B")
    FactoryGirl.create(:dependency_condition, :dependency => @dependency, :rule_key => "C")
    dc_ids = @dependency.dependency_conditions.map(&:id)
    @dependency.destroy
    dc_ids.each{|id| DependencyCondition.find_by_id(id).should == nil}
  end
end
