# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionGroup do
  let(:question_group) { FactoryBot.create(:question_group) }
  let(:dependency) { FactoryBot.create(:dependency) }
  let(:response_set) { FactoryBot.create(:response_set) }

  context 'when creating' do
    it 'is valid by default' do
      expect(question_group).to be_valid
    end
    it '#display_type = inline by default' do
      question_group.display_type = 'inline'
      expect(question_group.renderer).to eql(:inline)
    end
    it "#renderer == 'default' when #display_type = nil" do
      question_group.display_type = nil
      expect(question_group.renderer).to eql(:default)
    end
    it 'interprets symbolizes #display_type to #renderer' do
      question_group.display_type = 'foo'
      expect(question_group.renderer).to eql(:foo)
    end
    it 'reports DOM ready #css_class based on dependencies' do
      question_group.dependency = dependency
      expect(dependency).to receive(:is_met?).and_return(true)
      expect(question_group.css_class(response_set)).to eql('g_default g_dependent')

      expect(dependency).to receive(:is_met?).and_return(false)
      expect(question_group.css_class(response_set)).to eql('g_default g_dependent g_hidden')

      question_group.custom_class = 'foo bar'
      expect(dependency).to receive(:is_met?).and_return(false)
      expect(question_group.css_class(response_set)).to eql('g_default g_dependent g_hidden foo bar')
    end
  end

  context 'with translations' do
    require 'yaml'
    let(:survey) { FactoryBot.create(:survey) }
    let(:survey_section) { FactoryBot.create(:survey_section) }
    let(:survey_translation) do
      FactoryBot.create(:survey_translation, locale: :es, translation: {
        question_groups: {
          goodbye: {
            text: '¡Adios!',
          },
        },
      }.to_yaml)
    end
    let(:question) { FactoryBot.create(:question) }
    before do
      question_group.text = 'Goodbye'
      question_group.reference_identifier = 'goodbye'
      question_group.questions = [question]
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it 'returns its own translation' do
      expect(question_group.translation(:es)[:text]).to eql('¡Adios!')
    end
    it 'returns its own default values' do
      expect(question_group.translation(:de)).to eql({ 'text' => 'Goodbye', 'help_text' => nil })
    end
  end
end
