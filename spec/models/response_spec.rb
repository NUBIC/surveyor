# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Response, 'when saving a response', type: :model do
  before(:each) do
    # @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 1)
    @response = FactoryBot.create(:response, question: FactoryBot.create(:question), answer: FactoryBot.create(:answer, response_class: :string))
  end

  it 'should be valid' do
    expect(@response).to be_valid
  end

  it 'should be invalid without a question' do
    @response.question_id = nil
    expect(@response).to have(1).error_on(:question_id)
  end

  it 'should be correct if the question has no correct_answer_id' do
    expect(@response.question.correct_answer_id).to be_nil
    expect(@response.correct?).to be(true)
  end

  it "should be correct if the answer's response class != answer" do
    expect(@response.answer.response_class).not_to eq('answer')
    expect(@response.correct?).to be(true)
  end

  it "should be (in)correct if answer_id is (not) equal to question's correct_answer_id" do
    @answer = FactoryBot.create(:answer, response_class: 'answer')
    @question = FactoryBot.create(:question, correct_answer: @answer)
    @response = FactoryBot.create(:response, question: @question, answer: @answer)
    expect(@response.correct?).to be(true)
    @response.answer = FactoryBot.create(:answer, response_class: 'answer').tap { |a| a.id = 143 }
    expect(@response.correct?).to be(false)
  end

  it 'should be in order by created_at' do
    expect(@response.response_set).not_to be_nil
    response2 = FactoryBot.create(:response, question: FactoryBot.create(:question), answer: FactoryBot.create(:answer), response_set: @response.response_set, created_at: (@response.created_at + 1))
    expect(Response.all).to eq([@response, response2])
  end

  describe 'returns the response as the type requested' do
    it "returns 'string'" do
      @response.string_value = 'blah'
      expect(@response.as('string')).to eq('blah')
      expect(@response.as(:string)).to eq('blah')
    end

    it "returns 'integer'" do
      @response.integer_value = 1001
      expect(@response.as(:integer)).to eq(1001)
    end

    it "returns 'float'" do
      @response.float_value = 3.14
      expect(@response.as(:float)).to eq(3.14)
    end

    it "returns 'answer'" do
      @response.answer_id = 14
      expect(@response.as(:answer)).to eq(14)
    end

    it 'default returns answer type if not specified' do
      @response.answer_id = 18
      expect(@response.as(:stuff)).to eq(18)
    end

    it 'returns empty elements if the response is cast as a type that is not present' do
      resp = Response.new(question_id: 314, response_set_id: 156)
      expect(resp.as(:string)).to eq(nil)
      expect(resp.as(:integer)).to eq(nil)
      expect(resp.as(:float)).to eq(nil)
      expect(resp.as(:answer)).to eq(nil)
      expect(resp.as(:stuff)).to eq(nil)
    end
  end
end

describe Response, 'applicable_attributes', type: :model do
  before(:each) do
    @who = FactoryBot.create(:question, text: 'Who rules?')
    @odoyle = FactoryBot.create(:answer, text: 'Odoyle', response_class: 'answer')
    @other = FactoryBot.create(:answer, text: 'Other', response_class: 'string')
  end

  it 'should have string_value if response_type is string' do
    good = { 'question_id' => @who.id, 'answer_id' => @other.id, 'string_value' => 'Frank' }
    expect(Response.applicable_attributes(good)).to eq(good)
  end

  it 'should not have string_value if response_type is answer' do
    bad = { 'question_id' => @who.id, 'answer_id' => @odoyle.id, 'string_value' => 'Frank' }
    expect(Response.applicable_attributes(bad))
      .to eq({ 'question_id' => @who.id, 'answer_id' => @odoyle.id })
  end

  it 'should have string_value if response_type is string and answer_id is an array (in the case of checkboxes)' do
    good = { 'question_id' => @who.id, 'answer_id' => ['', @odoyle.id], 'string_value' => 'Frank' }
    expect(Response.applicable_attributes(good))
      .to eq({ 'question_id' => @who.id, 'answer_id' => ['', @odoyle.id] })
  end

  it 'should have ignore attribute if missing answer_id' do
    ignore = { 'question_id' => @who.id, 'answer_id' => '', 'string_value' => 'Frank' }
    expect(Response.applicable_attributes(ignore))
      .to eq({ 'question_id' => @who.id, 'answer_id' => '', 'string_value' => 'Frank' })
  end

  it 'should have ignore attribute if missing answer_id is an array' do
    ignore = { 'question_id' => @who.id, 'answer_id' => [''], 'string_value' => 'Frank' }
    expect(Response.applicable_attributes(ignore))
      .to eq({ 'question_id' => @who.id, 'answer_id' => [''], 'string_value' => 'Frank' })
  end
end

describe Response, '#to_formatted_s', type: :model do
  context 'when datetime' do
    let(:r) { Response.new(answer: Answer.new(response_class: 'datetime')) }

    it 'returns "" when nil' do
      r.datetime_value = nil

      expect(r.to_formatted_s).to eq('')
    end
  end
end

describe Response, '#json_value', type: :model do
  context 'when integer' do
    let(:r) { Response.new(integer_value: 2, answer: Answer.new(response_class: 'integer')) }
    it 'should be 2' do
      expect(r.json_value).to eq(2)
    end
  end

  context 'when float' do
    let(:r) { Response.new(float_value: 3.14, answer: Answer.new(response_class: 'float')) }
    it 'should be 3.14' do
      expect(r.json_value).to eq(3.14)
    end
  end

  context 'when string' do
    let(:r) { Response.new(string_value: 'bar', answer: Answer.new(response_class: 'string')) }
    it "should be 'bar'" do
      expect(r.json_value).to eq('bar')
    end
  end

  context 'when datetime' do
    let(:r) { Response.new(datetime_value: DateTime.strptime('2010-04-08T10:30+00:00', '%Y-%m-%dT%H:%M%z'), answer: Answer.new(response_class: 'datetime')) }
    it "should be '2010-04-08T10:30+00:00'" do
      expect(r.json_value).to eq('2010-04-08T10:30+00:00')
      expect(r.json_value.to_json).to eq('"2010-04-08T10:30+00:00"')
    end
  end

  context 'when date' do
    let(:r) { Response.new(datetime_value: DateTime.strptime('2010-04-08', '%Y-%m-%d'), answer: Answer.new(response_class: 'date')) }
    it "should be '2010-04-08'" do
      expect(r.json_value).to eq('2010-04-08')
      expect(r.json_value.to_json).to eq('"2010-04-08"')
    end
  end

  context 'when time' do
    let(:r) { Response.new(datetime_value: DateTime.strptime('10:30', '%H:%M'), answer: Answer.new(response_class: 'time')) }
    it "should be '10:30'" do
      expect(r.json_value).to eq('10:30')
      expect(r.json_value.to_json).to eq('"10:30"')
    end
  end
end

describe Response, 'value methods', type: :model do
  let(:response) { Response.new }

  describe '#date_value=' do
    it 'accepts a parseable date string' do
      response.date_value = '2010-01-15'
      expect(response.datetime_value.strftime('%Y %m %d')).to eq('2010 01 15')
    end

    it 'clears when given nil' do
      response.datetime_value = Time.new
      response.date_value = nil
      expect(response.datetime_value).to be_nil
    end
  end

  describe 'time_value=' do
    it 'accepts a parseable time string' do
      response.time_value = '11:30'
      expect(response.datetime_value.strftime('%H %M %S')).to eq('11 30 00')
    end

    it 'clears when given nil' do
      response.datetime_value = Time.new
      response.time_value = nil
      expect(response.datetime_value).to be_nil
    end
  end
end
