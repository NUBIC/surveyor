# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveySection do
  let(:survey_section) { FactoryBot.create(:survey_section) }

  context 'when creating' do
    it 'is invalid without #title' do
      survey_section.title = nil
      expect(survey_section).to have(1).error_on(:title)
    end
  end

  context 'with questions' do
    let(:question_1) { FactoryBot.create(:question, survey_section: survey_section, display_order: 3, text: 'Peep') }
    let(:question_2) { FactoryBot.create(:question, survey_section: survey_section, display_order: 1, text: 'Little') }
    let(:question_3) { FactoryBot.create(:question, survey_section: survey_section, display_order: 2, text: 'Bo') }
    before do
      [question_1, question_2, question_3].each { |q| survey_section.questions << q }
    end
    it 'has three questions' do
      expect(survey_section).to have(3).questions
    end
    it 'gets questions in order' do
      expect(survey_section.questions.order(display_order: :asc).to_a).to eql([question_2, question_3, question_1])
      expect(survey_section.questions.order(display_order: :asc).map(&:display_order)).to eq([1, 2, 3])
    end
    it 'deletes child questions when deleted' do
      question_ids = survey_section.questions.map(&:id)
      survey_section.destroy
      question_ids.each do |id|
        expect(Question.find_by_id(id)).to be(nil)
      end
    end
  end

  context 'with translations' do
    require 'yaml'
    let(:survey) { FactoryBot.create(:survey) }
    let(:survey_translation) do
      FactoryBot.create(:survey_translation, locale: :es, translation: {
        survey_sections: {
          one: {
            title: 'Uno',
          },
        },
      }.to_yaml)
    end
    before do
      survey_section.reference_identifier = 'one'
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it 'returns its own translation' do
      expect(YAML.safe_load(survey_translation.translation, [Symbol])).not_to be(nil)
      expect(survey_section.translation(:es)[:title]).to eql('Uno')
    end
    it 'returns its own default values' do
      expect(survey_section.translation(:de)).to eql({ 'title' => survey_section.title, 'description' => survey_section.description })
    end
  end

  describe 'completed' do
    let!(:survey) { FactoryBot.create(:survey) }
    let!(:empty_section) { FactoryBot.create(:survey_section, survey: survey) }

    let!(:no_mandatory_section) { FactoryBot.create(:survey_section, survey: survey) }
    let!(:no_mandatory_optional_question) do
      FactoryBot.create(:question,
        survey_section_id: no_mandatory_section.id,
        is_mandatory: false)
    end
    let!(:no_mandatory_optional_answer) do
      FactoryBot.create(:answer,
        question: no_mandatory_optional_question,
        response_class: :string)
    end

    let!(:mixed_section) { FactoryBot.create(:survey_section, survey: survey) }
    let!(:mixed_optional_question_1) do
      FactoryBot.create(:question,
        survey_section_id: mixed_section.id,
        is_mandatory: false)
    end
    let!(:mixed_optional_answer_1) do
      FactoryBot.create(:answer,
        question: mixed_optional_question_1,
        response_class: :string)
    end
    let!(:mixed_optional_question_2) do
      FactoryBot.create(:question,
        survey_section_id: mixed_section.id,
        is_mandatory: false)
    end
    let!(:mixed_optional_answer_2) do
      FactoryBot.create(:answer,
        question: mixed_optional_question_2,
        response_class: :string)
    end
    let!(:mixed_mandatory_question_1) do
      FactoryBot.create(:question,
        survey_section_id: mixed_section.id,
        is_mandatory: true)
    end
    let!(:mixed_mandatory_answer_1) do
      FactoryBot.create(:answer,
        question: mixed_mandatory_question_1,
        response_class: :string)
    end
    let!(:mixed_mandatory_question_2) do
      FactoryBot.create(:question,
        survey_section_id: mixed_section.id,
        is_mandatory: true)
    end
    let!(:mixed_mandatory_answer_2) do
      FactoryBot.create(:answer,
        question: mixed_mandatory_question_2,
        response_class: :string)
    end

    let!(:dependency_section) { FactoryBot.create(:survey_section, survey: survey) }
    let!(:dependency_mandatory_question) do
      FactoryBot.create(:question,
        survey_section_id: dependency_section.id,
        is_mandatory: true)
    end
    let!(:dependency_mandatory_answer) do
      FactoryBot.create(:answer,
        question: dependency_mandatory_question,
        response_class: :string)
    end
    let!(:dependency_mandatory_dependency) do
      FactoryBot.create(:dependency,
        question: dependency_mandatory_question)
    end
    let!(:dependency_mandatory_dependency_condition) do
      FactoryBot.create(:dependency_condition,
        dependency: dependency_mandatory_dependency,
        question_id: mixed_mandatory_question_1.id,
        answer_id: mixed_mandatory_answer_1.id,
        string_value: 'answer')
    end

    let!(:new_set) { ResponseSet.create(survey: survey) }

    it 'should indicate that a section is complete if there are no questions in the section' do
      expect(empty_section.completed?(new_set)).to be(true)
    end

    it 'should indicate that a section is complete if there are no mandatory questions in the section' do
      expect(no_mandatory_section.completed?(new_set)).to be(true)

      new_set.responses.build(
        question_id: no_mandatory_optional_question.id,
        answer_id: no_mandatory_optional_answer.id,
        string_value: 'answer',
      )
      expect(new_set.save).to be(true)
      expect(no_mandatory_section.completed?(new_set)).to be(true)
    end

    it 'should indicate that a section is not complete if there are no responses for a mandatory question in the section' do
      expect(mixed_section.completed?(new_set)).to be(false)
    end

    it 'should indicate that a section is complete if the mandatory questions in the section are complete' do
      new_set.responses.build(
        question_id: mixed_mandatory_question_1.id,
        answer_id: mixed_mandatory_answer_1.id,
        string_value: 'answer',
      )
      new_set.responses.build(
        question_id: mixed_mandatory_question_2.id,
        answer_id: mixed_mandatory_answer_2.id,
        string_value: 'answer',
      )
      expect(new_set.save).to be(true)
      expect(mixed_section.completed?(new_set)).to be(true)
    end

    it 'should indicate that a section is not complete if only some mandatory questions in the section are complete' do
      expect(mixed_section.completed?(new_set)).to be(false)

      new_set.responses.build(
        question_id: mixed_mandatory_question_1.id,
        answer_id: mixed_mandatory_answer_1.id,
        string_value: 'answer',
      )
      expect(new_set.save).to be(true)

      expect(mixed_section.completed?(new_set)).to be(false)
    end

    it 'should indicate that a section is complete if some optional questions in the section are complete' do
      expect(mixed_section.completed?(new_set)).to be(false)

      new_set.responses.build(
        question_id: mixed_optional_question_1.id,
        answer_id: mixed_optional_answer_1.id,
        string_value: 'answer',
      )
      new_set.responses.build(
        question_id: mixed_mandatory_question_1.id,
        answer_id: mixed_mandatory_answer_1.id,
        string_value: 'answer',
      )
      new_set.responses.build(
        question_id: mixed_mandatory_question_2.id,
        answer_id: mixed_mandatory_answer_2.id,
        string_value: 'answer',
      )
      expect(new_set.save).to be(true)
      expect(mixed_section.completed?(new_set)).to be(true)
    end

    it 'should indicate that a section is not complete if a mandatory question is answered with a blank value' do
      expect(mixed_section.completed?(new_set)).to be(false)

      new_set.responses.build(
        question_id: mixed_mandatory_question_1.id,
        answer_id: mixed_mandatory_answer_1.id,
        string_value: '',
      )
      new_set.responses.build(
        question_id: mixed_mandatory_question_2.id,
        answer_id: mixed_mandatory_answer_2.id,
        string_value: 'answer',
      )
      expect(new_set.save).to be(true)
      expect(mixed_section.completed?(new_set)).to be(false)

      new_set.responses.build(
        question_id: mixed_mandatory_question_1.id,
        answer_id: mixed_mandatory_answer_1.id,
        string_value: 'answer',
      )
      new_set.save!
      expect(mixed_section.completed?(new_set)).to be(true)
    end

    it 'should indicate that a section is complete if a mandatory question is not shown and is not answered' do
      expect(dependency_section.completed?(new_set)).to be(true)

      new_set.responses.build(
        question_id: mixed_mandatory_question_1.id,
        answer_id: mixed_mandatory_answer_1.id,
        string_value: 'answer',
      )
      new_set.responses.build(
        question_id: mixed_mandatory_question_2.id,
        answer_id: mixed_mandatory_answer_2.id,
        string_value: 'answer',
      )
      new_set.save!
      expect(dependency_section.completed?(new_set)).to be(false)

      new_set.responses.build(
        question_id: dependency_mandatory_question.id,
        answer_id: dependency_mandatory_answer.id,
        string_value: 'answer',
      )
      new_set.save!
      expect(dependency_section.completed?(new_set)).to be(true)
    end
  end
end
