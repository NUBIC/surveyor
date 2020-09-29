# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ValidationCondition, type: :model do
  before(:each) do
    @validation_condition = FactoryBot.create(:validation_condition)
  end

  it 'should be valid' do
    expect(@validation_condition).to be_valid
  end
  # this causes issues with building and saving
  # it "should be invalid without a parent validation_id" do
  #   @validation_condition.validation_id = nil
  #   @validation_condition.should have(1).errors_on(:validation_id)
  # end

  it 'should be invalid without an operator' do
    @validation_condition.operator = nil
    expect(@validation_condition).to have(2).errors_on(:operator)
  end

  it 'should be invalid without a rule_key' do
    expect(@validation_condition).to be_valid
    @validation_condition.rule_key = nil
    expect(@validation_condition).not_to be_valid
    expect(@validation_condition).to have(1).errors_on(:rule_key)
  end

  it 'should have unique rule_key within the context of a validation' do
    expect(@validation_condition).to be_valid
    FactoryBot.create(:validation_condition, validation_id: 2, rule_key: '2')
    @validation_condition.rule_key = '2' # rule key uniquness is scoped by validation_id
    @validation_condition.validation_id = 2
    expect(@validation_condition).not_to be_valid
    expect(@validation_condition).to have(1).errors_on(:rule_key)
  end

  it 'should have an operator in Surveyor::Common::OPERATORS' do
    Surveyor::Common::OPERATORS.each do |o|
      @validation_condition.operator = o
      expect(@validation_condition).to have(0).errors_on(:operator)
    end
    @validation_condition.operator = '#'
    expect(@validation_condition).to have(1).error_on(:operator)
  end
end

describe ValidationCondition, 'validating responses', type: :model do
  def test_var(vhash, ahash, rhash)
    v = FactoryBot.create(:validation_condition, vhash)
    a = FactoryBot.create(:answer, ahash)
    r = FactoryBot.create(:response, { answer: a, question: a.question }.merge(rhash))
    v.is_valid?(r)
  end

  it 'should validate a response by regexp' do
    expect(test_var({ operator: '=~', regexp: /^[a-z]{1,6}$/.to_s }, { response_class: 'string' }, { string_value: 'clear' })).to be(true)
    expect(test_var({ operator: '=~', regexp: /^[a-z]{1,6}$/.to_s }, { response_class: 'string' }, { string_value: 'foobarbaz' })).to be(false)
  end
  it 'should validate a response by integer comparison' do
    expect(test_var({ operator: '>', integer_value: 3 }, { response_class: 'integer' }, { integer_value: 4 })).to be(true)
    expect(test_var({ operator: '<=', integer_value: 256 }, { response_class: 'integer' }, { integer_value: 512 })).to be(false)
  end
  it 'should validate a response by (in)equality' do
    expect(test_var({ operator: '!=', datetime_value: Date.today + 1 }, { response_class: 'date' }, { datetime_value: Date.today })).to be(true)
    expect(test_var({ operator: '==', string_value: 'foo' }, { response_class: 'string' }, { string_value: 'foo' })).to be(true)
  end
  it 'should represent itself as a hash' do
    @v = FactoryBot.create(:validation_condition, rule_key: 'A')
    allow(@v).to receive(:is_valid?).and_return(true)
    expect(@v.to_hash('foo')).to eq({ A: true })
    allow(@v).to receive(:is_valid?).and_return(false)
    expect(@v.to_hash('foo')).to eq({ A: false })
  end
end

describe ValidationCondition, 'validating responses by other responses', type: :model do
  def test_var(v_hash, a_hash, r_hash, ca_hash, cr_hash)
    ca = FactoryBot.create(:answer, ca_hash)
    cr = FactoryBot.create(:response, cr_hash.merge(answer: ca, question: ca.question))
    v = FactoryBot.create(:validation_condition, v_hash.merge({ question_id: ca.question.id, answer_id: ca.id }))
    a = FactoryBot.create(:answer, a_hash)
    r = FactoryBot.create(:response, r_hash.merge(answer: a, question: a.question))
    v.is_valid?(r)
  end
  it 'should validate a response by integer comparison' do
    expect(test_var({ operator: '>' }, { response_class: 'integer' }, { integer_value: 4 }, { response_class: 'integer' }, { integer_value: 3 })).to be(true)
    expect(test_var({ operator: '<=' }, { response_class: 'integer' }, { integer_value: 512 }, { response_class: 'integer' }, { integer_value: 4 })).to be(false)
  end
  it 'should validate a response by (in)equality' do
    expect(test_var({ operator: '!=' }, { response_class: 'date' }, { datetime_value: Date.today }, { response_class: 'date' }, { datetime_value: Date.today + 1 })).to be(true)
    expect(test_var({ operator: '==' }, { response_class: 'string' }, { string_value: 'donuts' }, { response_class: 'string' }, { string_value: 'donuts' })).to be(true)
  end
  it 'should not validate a response by regexp' do
    expect(test_var({ operator: '=~' }, { response_class: 'date' }, { datetime_value: Date.today }, { response_class: 'date' }, { datetime_value: Date.today + 1 })).to be(false)
    expect(test_var({ operator: '=~' }, { response_class: 'string' }, { string_value: 'donuts' }, { response_class: 'string' }, { string_value: 'donuts' })).to be(false)
  end
end
