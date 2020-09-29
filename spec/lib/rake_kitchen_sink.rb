# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'rake'

describe Surveyor::Parser do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require 'lib/tasks/surveyor_tasks'
    Rake::Task.define_task(:environment)
  end
  it 'should return properly parse the kitchen sink survey' do
    ENV['FILE'] = 'surveys/kitchen_sink_survey.rb'
    @rake['surveyor'].invoke

    expect(Survey.count).to eq(1)
    expect(SurveySection.count).to eq(2)
    expect(Question.count).to eq(44)
    expect(Answer.count).to eq(241)
    expect(Dependency.count).to eq(6)
    expect(DependencyCondition.count).to eq(9)
    expect(QuestionGroup.count).to eq(6)

    Survey.all.map(&:destroy)
  end
  it 'should return properly parse a UTF8 survey' do
    ENV['FILE'] = '../spec/fixtures/chinese_survey.rb'
    @rake['surveyor'].invoke

    expect(Survey.count).to eq(1)
    expect(SurveySection.count).to eq(1)
    expect(Question.count).to eq(3)
    expect(Answer.count).to eq(15)
    expect(Dependency.count).to eq(0)
    expect(DependencyCondition.count).to eq(0)
    expect(QuestionGroup.count).to eq(1)

    Survey.all.map(&:destroy)
  end
end
