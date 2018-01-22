require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SkipLogic do

  let!( :skip_logic ) { FactoryBot.create(:skip_logic) }

  it "should be valid" do
    skip_logic.should be_valid
  end

  it "should be invalid without a rule" do
    skip_logic.rule = nil
    skip_logic.should have(2).errors_on(:rule)
    skip_logic.rule = " "
    skip_logic.should have(1).errors_on(:rule)
  end

  it "should be invalid without a survey_section" do
    skip_logic.survey_section_id = nil
    skip_logic.should have(1).error_on(:survey_section)

    skip_logic.survey_section_id = 1
    skip_logic.should be_valid
  end

  it "should be invalid unless rule composed of only references and operators" do
    skip_logic.rule = "foo"
    skip_logic.should have(1).error_on(:rule)
    skip_logic.rule = "1 to 2"
    skip_logic.should have(1).error_on(:rule)
    skip_logic.rule = "a and b"
    skip_logic.should have(1).error_on(:rule)
  end
end

describe SkipLogic, "when evaluating skip logic conditions of a section in a response set" do
  let!( :sl ) { SkipLogic.new(:rule => "A", :survey_section_id => 1, :target_survey_section_id => 2) }
  let!( :sl2 ) { SkipLogic.new(:rule => "A and B", :survey_section_id => 1, :target_survey_section_id => 2) }
  let!( :sl3 ) { SkipLogic.new(:rule => "A or B", :survey_section_id => 1, :target_survey_section_id => 2) }
  let!( :sl4 ) { SkipLogic.new(:rule => "!(A and B) and C", :survey_section_id => 1, :target_survey_section_id => 2) }

  let!( :sl_c_a ) { mock_model(SkipLogicCondition, :id => 1, :rule_key => "A", :to_hash => {:A => true}) }
  let!( :sl_c_b ) { mock_model(SkipLogicCondition, :id => 2, :rule_key => "B", :to_hash => {:B => false}) }
  let!( :sl_c_c ) { mock_model(SkipLogicCondition, :id => 3, :rule_key => "C", :to_hash => {:C => true}) }

  before( :each ) do
    sl.stub(:skip_logic_conditions).and_return([sl_c_a])
    sl2.stub(:skip_logic_conditions).and_return([sl_c_a, sl_c_b])
    sl3.stub(:skip_logic_conditions).and_return([sl_c_a, sl_c_b])
    sl4.stub(:skip_logic_conditions).and_return([sl_c_a, sl_c_b, sl_c_c])
  end

  it "knows if the skip logics are met" do
    sl.is_met?(@response_set).should be_true
    sl2.is_met?(@response_set).should be_false
    sl3.is_met?(@response_set).should be_true
    sl4.is_met?(@response_set).should be_true
  end

  it "returns the proper keyed pairs from the dependency conditions" do
    sl.conditions_hash(@response_set).should == {:A => true}
    sl2.conditions_hash(@response_set).should == {:A => true, :B => false}
    sl3.conditions_hash(@response_set).should == {:A => true, :B => false}
    sl4.conditions_hash(@response_set).should == {:A => true, :B => false, :C => true}
  end
end

describe SkipLogic, "with conditions" do
  it "should destroy conditions when destroyed" do
    skip_logic = SkipLogic.new(:rule => "A and B and C", :survey_section_id => 1)
    FactoryBot.create(:skip_logic_condition, :skip_logic => skip_logic, :rule_key => "A")
    FactoryBot.create(:skip_logic_condition, :skip_logic => skip_logic, :rule_key => "B")
    FactoryBot.create(:skip_logic_condition, :skip_logic => skip_logic, :rule_key => "C")
    slc_ids = skip_logic.skip_logic_conditions.map(&:id)
    skip_logic.destroy
    slc_ids.each{|id| SkipLogicCondition.find_by_id(id).should be nil}
  end
end
