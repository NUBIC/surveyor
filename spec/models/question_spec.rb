# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question, type: :model do
  let(:question) { FactoryBot.create(:question) }

  context 'when creating' do
    it 'is invalid without #text' do
      question.text = nil
      expect(question).to have(1).error_on :text
    end
    it '#is_mandantory == false by default' do
      expect(question.mandatory?).to be(false)
    end
    it 'converts #pick to string' do
      expect(question.pick).to eq('none')
      question.pick = :one
      expect(question.pick).to eq('one')
      question.pick = nil
      expect(question.pick).to eq(nil)
    end
    it "#renderer == 'default' when #display_type = nil" do
      question.display_type = nil
      expect(question.renderer).to eq(:default)
    end
    it 'has #api_id with 36 characters by default' do
      expect(question.api_id.length).to eq(36)
    end
    it '#part_of_group? and #solo? are aware of question groups' do
      question.question_group = FactoryBot.create(:question_group)
      expect(question.solo?).to be(false)
      expect(question.part_of_group?).to be(true)

      question.question_group = nil
      expect(question.solo?).to be(true)
      expect(question.part_of_group?).to be(false)
    end
  end

  context 'with answers' do
    let(:answer_1) { FactoryBot.create(:answer, question: question, display_order: 3, text: 'blue') }
    let(:answer_2) { FactoryBot.create(:answer, question: question, display_order: 1, text: 'red') }
    let(:answer_3) { FactoryBot.create(:answer, question: question, display_order: 2, text: 'green') }
    before do
      [answer_1, answer_2, answer_3].each { |a| question.answers << a }
    end
    it { expect(question).to have(3).answers }
    it 'gets answers in order' do
      expect(question.answers.order('display_order asc')).to eq([answer_2, answer_3, answer_1])
      expect(question.answers.order('display_order asc').map(&:display_order)).to eq([1, 2, 3])
    end
    it 'deletes child answers when deleted' do
      answer_ids = question.answers.map(&:id)
      question.destroy
      answer_ids.each { |id| expect(Answer.find_by_id(id)).to be_nil }
    end
  end

  context 'with dependencies' do
    let(:response_set) { FactoryBot.create(:response_set) }
    let(:dependency) { FactoryBot.create(:dependency) }
    before do
      question.dependency = dependency
      allow(dependency).to receive(:is_met?).with(response_set).and_return true
    end
    it 'checks its dependency' do
      expect(question.triggered?(response_set)).to be(true)
    end
    it 'deletes its dependency when deleted' do
      d_id = question.dependency.id
      question.destroy
      expect(Dependency.find_by_id(d_id)).to be_nil
    end
  end

  context 'with mustache text substitution' do
    require 'mustache'
    let(:mustache_context) do
      Class.new(::Mustache) do
        def site; 'Northwestern'; end

        def foo; 'bar'; end
      end
    end

    it 'subsitutes Mustache context variables' do
      question.text = 'You are in {{site}}'
      expect(question.in_context(question.text, mustache_context)).to eq('You are in Northwestern')
    end
    it 'substitues in views' do
      question.text = 'You are in {{site}}'
      expect(question.text_for(nil, mustache_context)).to eq('You are in Northwestern')
    end
  end

  context 'with translations' do
    require 'yaml'
    let(:survey) { FactoryBot.create(:survey) }
    let(:survey_section) { FactoryBot.create(:survey_section) }
    let(:survey_translation) do
      FactoryBot.create(:survey_translation, locale: :es, translation: {
        questions: {
          hello: {
            text: '¡Hola!',
          },
        },
      }.to_yaml)
    end
    before do
      question.reference_identifier = 'hello'
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it 'returns its own translation' do
      expect(YAML.safe_load(survey_translation.translation, [Symbol])).not_to be_nil
      expect(question.translation(:es)[:text]).to eq('¡Hola!')
    end
    it 'returns its own default values' do
      expect(question.translation(:de)).to eq({ 'text' => question.text, 'help_text' => question.help_text })
    end
    it 'returns translations in views' do
      expect(question.text_for(nil, nil, :es)).to eq('¡Hola!')
    end
    it 'returns default values in views' do
      expect(question.text_for(nil, nil, :de)).to eq(question.text)
    end
  end

  context 'handling strings' do
    it '#split preserves strings' do
      expect(question.split(question.text)).to eq('What is your favorite color?')
    end
    it '#split(:pre) preserves strings' do
      expect(question.split(question.text, :pre)).to eq('What is your favorite color?')
    end
    it '#split(:post) preserves strings' do
      expect(question.split(question.text, :post)).to eq('')
    end
    it '#split splits strings' do
      question.text = 'before|after|extra'
      expect(question.split(question.text)).to eq('before|after|extra')
    end
    it '#split(:pre) splits strings' do
      question.text = 'before|after|extra'
      expect(question.split(question.text, :pre)).to eq('before')
    end
    it '#split(:post) splits strings' do
      question.text = 'before|after|extra'
      expect(question.split(question.text, :post)).to eq('after|extra')
    end
  end

  context 'for views' do
    it '#text_for preserves strings' do
      expect(question.text_for).to eq('What is your favorite color?')
    end
    it '#text_for(:pre) preserves strings' do
      expect(question.text_for(:pre)).to eq('What is your favorite color?')
    end
    it '#text_for(:post) preserves strings' do
      expect(question.text_for(:post)).to eq('')
    end
    it '#text_for splits strings' do
      question.text = 'before|after|extra'
      expect(question.text_for).to eq('before|after|extra')
    end
    it '#text_for(:pre) splits strings' do
      question.text = 'before|after|extra'
      expect(question.text_for(:pre)).to eq('before')
    end
    it '#text_for(:post) splits strings' do
      question.text = 'before|after|extra'
      expect(question.text_for(:post)).to eq('after|extra')
    end
  end

  describe 'qualified' do
    let!(:r_set) { FactoryBot.create(:response_set, survey: question.survey_section.survey) }

    describe 'with pick none' do
      before :each do
        expect(question.update_attribute(:pick, 'none')).to be true
      end

      it 'should always be qualified if the pick is "none"' do
        expect(question.qualified?(r_set)).to be true
      end
    end

    describe 'with pick one' do
      before :each do
        expect(question.update_attribute(:pick, 'one')).to be true
      end

      it 'should be qualified if the question is unanswered but not mandatory' do
        expect(question.update_attribute(:is_mandatory, false)).to be true
        expect(question.qualified?(r_set)).to be true
      end

      it 'should not be qualified if the question is unanswered but mandatory' do
        expect(question.update_attribute(:is_mandatory, true)).to be true
        expect(question.qualified?(r_set)).to be false
      end

      it 'should be qualified if a "may" answer is selected' do
        may_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'may')

        question.reload
        expect(question.update_attribute(:is_mandatory, true)).to be true
        expect(question.qualified?(r_set)).to be false

        r_set.responses.build(
          question_id: question.id,
          answer_id: may_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be true
      end

      it 'should not be qualified if a "reject" answer is selected' do
        reject_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'reject')
        question.reload

        expect(question.qualified?(r_set)).to be true

        r_set.responses.build(
          question_id: question.id,
          answer_id: reject_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be false
      end
    end

    describe 'with pick any' do
      before :each do
        expect(question.update_attribute(:pick, 'any')).to be true
      end

      it 'should be qualified if there are no answers available' do
        expect(question.qualified?(r_set)).to be true
      end

      it 'should be qualified if there are no answers available even if the question is mandatory' do
        expect(question.update_attribute(:is_mandatory, true)).to be true
        expect(question.qualified?(r_set)).to be true
      end

      it 'should not be qualified if a "reject" choice was made' do
        reject_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'reject')
        question.reload

        r_set.responses.build(
          question_id: question.id,
          answer_id: reject_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be false
      end

      it 'should be qualified if a "may" choice was made' do
        may_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'may')
        question.reload

        r_set.responses.build(
          question_id: question.id,
          answer_id: may_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be true
      end

      it 'should be qualified if a "must" choice was made' do
        must_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'must')
        question.reload

        r_set.responses.build(
          question_id: question.id,
          answer_id: must_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be true
      end

      it 'should be qualified if no selections where made and there is a a must selection and the question is not mandatory' do
        expect(question.update_attribute(:is_mandatory, false)).to be true
        must_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'must')
        question.reload
        expect(question.qualified?(r_set)).to be true
      end

      it 'should not be qualified if no selections where made and there is a a must selection and the question is mandatory' do
        expect(question.update_attribute(:is_mandatory, true)).to be true
        must_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'must')
        question.reload
        expect(question.qualified?(r_set)).to be false
      end

      it 'should not be qualified if some selections were made and there is a a must selection and the question is not mandatory' do
        expect(question.update_attribute(:is_mandatory, false)).to be true
        must_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'must')
        may_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'may')

        r_set.responses.build(
          question_id: question.id,
          answer_id: may_answer.id,
        )

        question.reload
        expect(question.qualified?(r_set)).to be false
      end

      it 'should not be qualified if only some must answers were selected' do
        first_must_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'must')
        second_must_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'must')
        question.reload

        r_set.responses.build(
          question_id: question.id,
          answer_id: first_must_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be false

        r_set.responses.build(
          question_id: question.id,
          answer_id: second_must_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be true
      end

      it 'should not be qualified if some may and some reject answers were selected' do
        reject_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'reject')
        may_answer = FactoryBot.create(:answer, question: question, qualify_logic: 'may')
        question.reload

        r_set.responses.build(
          question_id: question.id,
          answer_id: may_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be true

        r_set.responses.build(
          question_id: question.id,
          answer_id: reject_answer.id,
        )
        expect(r_set.save).to be true
        expect(question.qualified?(r_set)).to be false
      end
    end
  end
end
