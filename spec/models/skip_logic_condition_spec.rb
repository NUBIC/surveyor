# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SkipLogicCondition, type: :model do
  it 'should have a list of operators' do
    %w(== != < > <= >=).each do |operator|
      expect(SkipLogicCondition.operators.include?(operator)).to be(true)
    end
  end

  describe 'instance' do
    let!(:skip_logic_condition) do
      SkipLogicCondition.new(
        skip_logic: FactoryBot.create(:skip_logic),
        question: FactoryBot.create(:question),
        operator: '==',
        answer_id: 23,
        rule_key: 'A',
      )
    end

    it 'should be valid' do
      expect(skip_logic_condition).to be_valid
    end

    it 'should be invalid without a parent skip_logic, question_id' do
      skip_logic_condition.skip_logic_id = nil
      expect(skip_logic_condition).to have(1).errors_on(:skip_logic)
      skip_logic_condition.question_id = nil
      expect(skip_logic_condition).to have(1).errors_on(:question)
    end

    it 'should be invalid without an operator' do
      skip_logic_condition.operator = nil
      expect(skip_logic_condition).to have(2).errors_on(:operator)
    end

    it 'should be invalid without a rule_key' do
      expect(skip_logic_condition).to be_valid
      skip_logic_condition.rule_key = nil
      expect(skip_logic_condition).not_to be_valid
      expect(skip_logic_condition).to have(1).errors_on(:rule_key)
    end

    it 'should have unique rule_key within the context of a skip_logic' do
      expect(skip_logic_condition).to be_valid
      skip_logic = FactoryBot.create(:skip_logic)
      expect(SkipLogicCondition.create(
               skip_logic: skip_logic,
               question: FactoryBot.create(:question),
               operator: '==',
               answer_id: 14,
               rule_key: 'B',
             )).to be_valid
      skip_logic_condition.rule_key = 'B' # rule key uniquness is scoped by skip_logic_id
      skip_logic_condition.skip_logic_id = skip_logic.id
      expect(skip_logic_condition).not_to be_valid
      expect(skip_logic_condition).to have(1).errors_on(:rule_key)
    end

    it 'should have an operator in SkipLogicCondition.operators' do
      SkipLogicCondition.operators.each do |o|
        skip_logic_condition.operator = o
        expect(skip_logic_condition).to have(0).errors_on(:operator)
      end
      skip_logic_condition.operator = '#'
      expect(skip_logic_condition).to have(1).error_on(:operator)
    end
    it 'should have a properly formed count operator' do
      %w(count>1 count<1 count>=1 count<=1 count==1 count!=1).each do |o|
        skip_logic_condition.operator = o
        expect(skip_logic_condition).to have(0).errors_on(:operator)
      end
      %w(count> count< count>= count<= count== count!=).each do |o|
        skip_logic_condition.operator = o
        expect(skip_logic_condition).to have(1).errors_on(:operator)
      end
      %w(count=1 count><1 count<>1 count!1 count!!1 count=>1 count=<1).each do |o|
        skip_logic_condition.operator = o
        expect(skip_logic_condition).to have(1).errors_on(:operator)
      end
      %w(count= count>< count<> count! count!! count=> count=< count> count< count>= count<= count== count!=).each do |o|
        skip_logic_condition.operator = o
        expect(skip_logic_condition).to have(1).errors_on(:operator)
      end
    end
  end

  it 'returns true for != with no responses' do
    question = FactoryBot.create(:question)
    skip_logic_condition = FactoryBot.create(:skip_logic_condition, rule_key: 'C', question: question)
    rs = FactoryBot.create(:response_set)
    expect(skip_logic_condition.to_hash(rs)).to eq({ C: false })
  end

  it 'should not assume that Response#as is not nil' do
    # q_HEIGHT_FT "Portion of height in whole feet (e.g., 5)",
    # :pick=>:one
    # a :integer
    # a_neg_1 "Refused"
    # a_neg_2 "Don't know"
    # label "Provided value is outside of the suggested range (4 to 7 feet). This value is admissible, but you may wish to verify."
    # skip_logic :rule=>"A or B"
    # condition_A :q_HEIGHT_FT, "<", {:integer_value => "4"}
    # condition_B :q_HEIGHT_FT, ">", {:integer_value => "7"}

    answer = FactoryBot.create(:answer, response_class: :integer)
    skip_logic_condition = SkipLogicCondition.new(
      skip_logic: FactoryBot.create(:skip_logic),
      question: answer.question,
      answer: answer,
      operator: '>',
      integer_value: 4,
      rule_key: 'A',
    )

    response = FactoryBot.create(:response, answer: answer, question: answer.question)
    response_set = response.response_set
    expect(response.integer_value).to eq(nil)

    expect(skip_logic_condition.to_hash(response_set)).to eq({ A: false })
  end

  describe "evaluate '==' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer, response_class: 'answer')
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a)
      @rs = @r.response_set.reload
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '==', rule_key: 'D')
      expect(@slc.as(:answer)).to eq(@r.as(:answer))
    end

    it 'with checkbox/radio type response' do
      expect(@slc.to_hash(@rs)).to eq({ D: true })
      @slc.answer = @b
      expect(@slc.to_hash(@rs)).to eq({ D: false })
    end

    it 'with string value response' do
      @a.update_attributes(response_class: 'string')
      update_response(string_value: 'hello123')
      @slc.string_value = 'hello123'
      expect(@slc.to_hash(@rs)).to eq({ D: true })
      update_response(string_value: 'foo_abc')
      expect(@slc.to_hash(@rs)).to eq({ D: false })
    end

    it 'with a text value response' do
      @a.update_attributes(response_class: 'text')
      update_response(text_value: 'hello this is some text for comparison')
      @slc.text_value = 'hello this is some text for comparison'
      expect(@slc.to_hash(@rs)).to eq({ D: true })
      update_response(text_value: 'Not the same text')
      expect(@slc.to_hash(@rs)).to eq({ D: false })
    end

    it 'with an integer value response' do
      @a.update_attributes(response_class: 'integer')
      update_response(integer_value: 10045)
      @slc.integer_value = 10045
      expect(@slc.to_hash(@rs)).to eq({ D: true })
      update_response(integer_value: 421)
      expect(@slc.to_hash(@rs)).to eq({ D: false })
    end

    it 'with a float value response' do
      @a.update_attributes(response_class: 'float')
      update_response(float_value: 121.1)
      @slc.float_value = 121.1
      expect(@slc.to_hash(@rs)).to eq({ D: true })
      update_response(float_value: 130.123)
      expect(@slc.to_hash(@rs)).to eq({ D: false })
    end
  end

  describe "evaluate '!=' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a)
      @rs = @r.response_set.reload
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '!=', rule_key: 'E')
      expect(@slc.as(:answer)).to eq(@r.as(:answer))
    end

    it 'with checkbox/radio type response' do
      expect(@slc.to_hash(@rs)).to eq({ E: false })
      @slc.answer_id = @a.id.to_i + 1
      expect(@slc.to_hash(@rs)).to eq({ E: true })
    end

    it 'with string value response' do
      @a.update_attributes(response_class: 'string')
      update_response(string_value: 'hello123')
      @slc.string_value = 'hello123'
      expect(@slc.to_hash(@rs)).to eq({ E: false })
      update_response(string_value: 'foo_abc')
      expect(@slc.to_hash(@rs)).to eq({ E: true })
    end

    it 'with a text value response' do
      @a.update_attributes(response_class: 'text')
      update_response(text_value: 'hello this is some text for comparison')
      @slc.text_value = 'hello this is some text for comparison'
      expect(@slc.to_hash(@rs)).to eq({ E: false })
      update_response(text_value: 'Not the same text')
      expect(@slc.to_hash(@rs)).to eq({ E: true })
    end

    it 'with an integer value response' do
      @a.update_attributes(response_class: 'integer')
      update_response(integer_value: 10045)
      @slc.integer_value = 10045
      expect(@slc.to_hash(@rs)).to eq({ E: false })
      update_response(integer_value: 421)
      expect(@slc.to_hash(@rs)).to eq({ E: true })
    end

    it 'with a float value response' do
      @a.update_attributes(response_class: 'float')
      update_response(float_value: 121.1)
      @slc.float_value = 121.1
      expect(@slc.to_hash(@rs)).to eq({ E: false })
      update_response(float_value: 130.123)
      expect(@slc.to_hash(@rs)).to eq({ E: true })
    end
  end

  describe "evaluate the '<' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a)
      @rs = @r.response_set
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '<', rule_key: 'F')
      expect(@slc.as(:answer)).to eq(@r.as(:answer))
    end

    it 'with an integer value response' do
      @a.update_attributes(response_class: 'integer')
      update_response(integer_value: 50)
      @slc.integer_value = 100
      expect(@slc.to_hash(@rs)).to eq({ F: true })
      update_response(integer_value: 421)
      expect(@slc.to_hash(@rs)).to eq({ F: false })
    end

    it 'with a float value response' do
      @a.update_attributes(response_class: 'float')
      update_response(float_value: 5.1)
      @slc.float_value = 121.1
      expect(@slc.to_hash(@rs)).to eq({ F: true })
      update_response(float_value: 130.123)
      expect(@slc.to_hash(@rs)).to eq({ F: false })
    end
  end

  describe "evaluate the '<=' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a)
      @rs = @r.response_set
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '<=', rule_key: 'G')
      expect(@slc.as(:answer)).to eq(@r.as(:answer))
    end

    it 'with an integer value response' do
      @a.update_attributes(response_class: 'integer')
      update_response(integer_value: 50)
      @slc.integer_value = 100
      expect(@slc.to_hash(@rs)).to eq({ G: true })
      update_response(integer_value: 100)
      expect(@slc.to_hash(@rs)).to eq({ G: true })
      update_response(integer_value: 421)
      expect(@slc.to_hash(@rs)).to eq({ G: false })
    end

    it 'with a float value response' do
      @a.update_attributes(response_class: 'float')
      update_response(float_value: 5.1)
      @slc.float_value = 121.1
      expect(@slc.to_hash(@rs)).to eq({ G: true })
      update_response(float_value: 121.1)
      expect(@slc.to_hash(@rs)).to eq({ G: true })
      update_response(float_value: 130.123)
      expect(@slc.to_hash(@rs)).to eq({ G: false })
    end
  end

  describe "evaluate the '>' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a)
      @rs = @r.response_set
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '>', rule_key: 'H')
      expect(@slc.as(:answer)).to eq(@r.as(:answer))
    end

    it 'with an integer value response' do
      @a.update_attributes(response_class: 'integer')
      update_response(integer_value: 50)
      @slc.integer_value = 100
      expect(@slc.to_hash(@rs)).to eq({ H: false })
      update_response(integer_value: 421)
      expect(@slc.to_hash(@rs)).to eq({ H: true })
    end

    it 'with a float value response' do
      @a.update_attributes(response_class: 'float')
      update_response(float_value: 5.1)
      @slc.float_value = 121.1
      expect(@slc.to_hash(@rs)).to eq({ H: false })
      update_response(float_value: 130.123)
      expect(@slc.to_hash(@rs)).to eq({ H: true })
    end
  end

  describe "evaluate the '>=' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a)
      @rs = @r.response_set
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '>=', rule_key: 'I')
      expect(@slc.as(:answer)).to eq(@r.as(:answer))
    end

    it 'with an integer value response', focus: true do
      @a.update_attributes(response_class: 'integer')
      update_response(integer_value: 50)
      @slc.integer_value = 100
      expect(@slc.to_hash(@rs)).to eq({ I: false })
      update_response(integer_value: 100)
      expect(@slc.to_hash(@rs)).to eq({ I: true })
      update_response(integer_value: 421)
      expect(@slc.to_hash(@rs)).to eq({ I: true })
    end

    it 'with a float value response' do
      @a.update_attributes(response_class: 'float')
      update_response(float_value: 5.1)
      @slc.float_value = 121.1
      expect(@slc.to_hash(@rs)).to eq({ I: false })
      update_response(float_value: 121.1)
      expect(@slc.to_hash(@rs)).to eq({ I: true })
      update_response(float_value: 130.123)
      expect(@slc.to_hash(@rs)).to eq({ I: true })
    end
  end

  describe 'evaluating with response_class string' do
    it 'should compare answer ids when the skip logic condition string_value is nil' do
      @a = FactoryBot.create(:answer, response_class: 'string')
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, string_value: '')
      @rs = @r.response_set.reload
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '==', rule_key: 'J')
      expect(@slc.to_hash(@rs)).to eq({ J: true })
    end

    it 'should compare strings when the skip logic condition string_value is not nil, even if it is blank' do
      @a = FactoryBot.create(:answer, response_class: 'string')
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, string_value: 'foo')
      @rs = @r.response_set.reload
      @slc = FactoryBot.create(:skip_logic_condition, question: @a.question, answer: @a, operator: '==', rule_key: 'K', string_value: 'foo')
      expect(@slc.to_hash(@rs)).to eq({ K: true })

      update_response(string_value: '')
      @slc.string_value = ''
      expect(@slc.to_hash(@rs)).to eq({ K: true })
    end
  end

  describe "evaluate 'count' operator" do
    before(:each) do
      @q = FactoryBot.create(:question)
      @slc = SkipLogicCondition.new(operator: 'count>2', rule_key: 'M', question: @q)
      @as = []
      3.times do
        @as << FactoryBot.create(:answer, question: @q, response_class: 'answer')
      end
      @rs = FactoryBot.create(:response_set)
      @as.slice(0, 2).each do |a|
        FactoryBot.create(:response, question: @q, answer: a, response_set: @rs)
      end
      @rs.save
      @rs.reload
    end

    it 'with operator with >' do
      expect(@slc.to_hash(@rs)).to eq({ M: false })
      FactoryBot.create(:response, question: @q, answer: @as.last, response_set: @rs)
      expect(@rs.reload.responses.count).to eq(3)
      expect(@slc.to_hash(@rs.reload)).to eq({ M: true })
    end

    it 'with operator with <' do
      @slc.operator = 'count<2'
      expect(@slc.to_hash(@rs)).to eq({ M: false })
      @slc.operator = 'count<3'
      expect(@slc.to_hash(@rs)).to eq({ M: true })
    end

    it 'with operator with <=' do
      @slc.operator = 'count<=1'
      expect(@slc.to_hash(@rs)).to eq({ M: false })
      @slc.operator = 'count<=2'
      expect(@slc.to_hash(@rs)).to eq({ M: true })
      @slc.operator = 'count<=3'
      expect(@slc.to_hash(@rs)).to eq({ M: true })
    end

    it 'with operator with >=' do
      @slc.operator = 'count>=1'
      expect(@slc.to_hash(@rs)).to eq({ M: true })
      @slc.operator = 'count>=2'
      expect(@slc.to_hash(@rs)).to eq({ M: true })
      @slc.operator = 'count>=3'
      expect(@slc.to_hash(@rs)).to eq({ M: false })
    end

    it 'with operator with !=' do
      @slc.operator = 'count!=1'
      expect(@slc.to_hash(@rs)).to eq({ M: true })
      @slc.operator = 'count!=2'
      expect(@slc.to_hash(@rs)).to eq({ M: false })
      @slc.operator = 'count!=3'
      expect(@slc.to_hash(@rs)).to eq({ M: true })
    end
  end

  def update_response(values)
    @r.update_attributes(values)
    @rs.reload
  end
end
