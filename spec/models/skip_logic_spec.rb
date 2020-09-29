# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SkipLogic, type: :model do
  let!(:skip_logic) { FactoryBot.create(:skip_logic) }

  it 'should be valid' do
    expect(skip_logic).to be_valid
  end

  it 'should be invalid without a rule' do
    skip_logic.rule = nil
    expect(skip_logic).to have(2).errors_on(:rule)
    skip_logic.rule = ' '
    expect(skip_logic).to have(1).errors_on(:rule)
  end

  it 'should be invalid without a survey_section' do
    skip_logic.survey_section_id = nil
    expect(skip_logic).to have(1).error_on(:survey_section)

    skip_logic.survey_section_id = 1
    expect(skip_logic).to be_valid
  end

  it 'should be invalid unless rule composed of only references and operators' do
    skip_logic.rule = 'foo'
    expect(skip_logic).to have(1).error_on(:rule)
    skip_logic.rule = '1 to 2'
    expect(skip_logic).to have(1).error_on(:rule)
    skip_logic.rule = 'a and b'
    expect(skip_logic).to have(1).error_on(:rule)
  end
end

describe SkipLogic, 'when evaluating skip logic conditions of a section in a response set', type: :model do
  let!(:sl) { SkipLogic.new(rule: 'A', survey_section_id: 1, target_survey_section_id: 2) }
  let!(:sl2) { SkipLogic.new(rule: 'A and B', survey_section_id: 1, target_survey_section_id: 2) }
  let!(:sl3) { SkipLogic.new(rule: 'A or B', survey_section_id: 1, target_survey_section_id: 2) }
  let!(:sl4) { SkipLogic.new(rule: '!(A and B) and C', survey_section_id: 1, target_survey_section_id: 2) }

  let!(:sl_c_a) { instance_double(SkipLogicCondition, id: 1, rule_key: 'A', to_hash: { A: true }) }
  let!(:sl_c_b) { instance_double(SkipLogicCondition, id: 2, rule_key: 'B', to_hash: { B: false }) }
  let!(:sl_c_c) { instance_double(SkipLogicCondition, id: 3, rule_key: 'C', to_hash: { C: true }) }

  before(:each) do
    allow(sl).to receive(:skip_logic_conditions).and_return([sl_c_a])
    allow(sl2).to receive(:skip_logic_conditions).and_return([sl_c_a, sl_c_b])
    allow(sl3).to receive(:skip_logic_conditions).and_return([sl_c_a, sl_c_b])
    allow(sl4).to receive(:skip_logic_conditions).and_return([sl_c_a, sl_c_b, sl_c_c])
  end

  it 'knows if the skip logics are met' do
    expect(sl.is_met?(@response_set)).to be(true)
    expect(sl2.is_met?(@response_set)).to be(false)
    expect(sl3.is_met?(@response_set)).to be(true)
    expect(sl4.is_met?(@response_set)).to be(true)
  end

  it 'returns the proper keyed pairs from the dependency conditions' do
    expect(sl.conditions_hash(@response_set)).to eq({ A: true })
    expect(sl2.conditions_hash(@response_set)).to eq({ A: true, B: false })
    expect(sl3.conditions_hash(@response_set)).to eq({ A: true, B: false })
    expect(sl4.conditions_hash(@response_set)).to eq({ A: true, B: false, C: true })
  end
end

describe SkipLogic, 'with conditions', type: :model do
  it 'should destroy conditions when destroyed' do
    skip_logic = SkipLogic.new(rule: 'A and B and C', survey_section_id: 1)
    FactoryBot.create(:skip_logic_condition, skip_logic: skip_logic, rule_key: 'A')
    FactoryBot.create(:skip_logic_condition, skip_logic: skip_logic, rule_key: 'B')
    FactoryBot.create(:skip_logic_condition, skip_logic: skip_logic, rule_key: 'C')
    slc_ids = skip_logic.skip_logic_conditions.map(&:id)
    skip_logic.destroy
    slc_ids.each { |id| expect(SkipLogicCondition.find_by_id(id)).to be nil }
  end
end
