# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveyorHelper, type: :helper do
  context 'numbering' do
    it 'should return the question text with number, except for labels, dependencies, images, and grouped questions' do
      q1 = FactoryBot.create(:question)
      q2 = FactoryBot.create(:question, display_type: 'label')
      q3 = FactoryBot.create(:question, dependency: FactoryBot.create(:dependency))
      q4 = FactoryBot.create(:question, display_type: 'image', text: 'rails.png')
      q5 = FactoryBot.create(:question, question_group: FactoryBot.create(:question_group))
      expect(helper.q_text(q1)).to eq("<span class='qnum'>1) </span>#{q1.text}")
      expect(helper.q_text(q2)).to eq(q2.text)
      expect(helper.q_text(q3)).to eq(q3.text)
      expect(helper.q_text(q5)).to eq(q5.text)
    end
  end

  context 'with mustache text substitution' do
    require 'mustache'

    let(:mustache_context) do
      Class.new(::Mustache) do
        def site; 'Northwestern'; end

        def somethingElse; 'something new'; end

        def group; 'NUBIC'; end
      end
    end

    it 'substitues values into Question#text' do
      q1 = FactoryBot.create(:question, text: 'You are in {{site}}')
      label = FactoryBot.create(:question, display_type: 'label', text: 'Testing {{somethingElse}}')
      expect(helper.q_text(q1, mustache_context)).to eq("<span class='qnum'>1) </span>You are in Northwestern")
      expect(helper.q_text(label, mustache_context)).to eq('Testing something new')
    end
  end

  context 'response methods' do
    it 'should find or create responses, with index' do
      q1 = FactoryBot.create(:question, answers: [a = FactoryBot.create(:answer, text: 'different')])
      q2 = FactoryBot.create(:question, answers: [b = FactoryBot.create(:answer, text: 'strokes')])
      q3 = FactoryBot.create(:question, answers: [c = FactoryBot.create(:answer, text: 'folks')])
      rs = FactoryBot.create(:response_set, responses: [r1 = FactoryBot.create(:response, question: q1, answer: a), r3 = FactoryBot.create(:response, question: q3, answer: c, response_group: 1)])

      expect(helper.r_for(rs, nil)).to eq(nil)
      expect(helper.r_for(nil, q1)).to eq(nil)
      expect(helper.r_for(rs, q1)).to eq(r1)
      expect(helper.r_for(rs, q1, a)).to eq(r1)
      expect(helper.r_for(rs, q2).attributes.reject { |k, _v| k == 'api_id' }).to eq(Response.new(question: q2, response_set: rs).attributes.reject { |k, _v| k == 'api_id' })
      expect(helper.r_for(rs, q2, b).attributes.reject { |k, _v| k == 'api_id' }).to eq(Response.new(question: q2, response_set: rs).attributes.reject { |k, _v| k == 'api_id' })
      expect(helper.r_for(rs, q3, c, '1')).to eq(r3)
    end
    it 'should keep an index of responses' do
      expect(helper.index).to eq('1')
      expect(helper.index).to eq('2')
      expect(helper.index(false)).to eq('2')
      expect(helper.index).to eq('3')
    end
    it 'should translate response class into attribute' do
      expect(helper.rc_to_attr(:string)).to eq(:string_value)
      expect(helper.rc_to_attr(:text)).to eq(:text_value)
      expect(helper.rc_to_attr(:integer)).to eq(:integer_value)
      expect(helper.rc_to_attr(:float)).to eq(:float_value)
      expect(helper.rc_to_attr(:datetime)).to eq(:datetime_value)
      expect(helper.rc_to_attr(:date)).to eq(:date_value)
      expect(helper.rc_to_attr(:time)).to eq(:time_value)
    end

    it 'should translate response class into as' do
      expect(helper.rc_to_as(:string)).to eq(:string)
      expect(helper.rc_to_as(:text)).to eq(:text)
      expect(helper.rc_to_as(:integer)).to eq(:string)
      expect(helper.rc_to_as(:float)).to eq(:string)
      expect(helper.rc_to_as(:datetime)).to eq(:string)
      expect(helper.rc_to_as(:date)).to eq(:string)
      expect(helper.rc_to_as(:time)).to eq(:string)
    end
  end

  context 'overriding methods' do
    before do
      module SurveyorHelper
        include Surveyor::Helpers::SurveyorHelperMethods
        alias :old_rc_to_as :rc_to_as
        def rc_to_as(type_sym)
          case type_sym.to_s
          when /(integer|float)/ then :string
          when /(datetime)/ then :datetime
          else type_sym
          end
        end
      end
    end
    it 'should translate response class into as' do
      expect(helper.rc_to_as(:string)).to eq(:string)
      expect(helper.rc_to_as(:text)).to eq(:text)
      expect(helper.rc_to_as(:integer)).to eq(:string)
      expect(helper.rc_to_as(:float)).to eq(:string)
      expect(helper.rc_to_as(:datetime)).to eq(:datetime)  # not string
      expect(helper.rc_to_as(:date)).to eq(:date)          # not string
      expect(helper.rc_to_as(:time)).to eq(:time)
    end
    after do
      module SurveyorHelper
        include Surveyor::Helpers::SurveyorHelperMethods
        def rc_to_as(type_sym)
          old_rc_to_as(type_sym)
        end
      end
    end
  end

  # run this context after 'overriding methods'
  context 'post override test' do
    # Sanity check
    it 'should translate response class into as after override' do
      expect(helper.rc_to_as(:datetime)).to eq(:string)  # back to string
      expect(helper.rc_to_as(:date)).to eq(:string)      # back to string
    end
  end
end
