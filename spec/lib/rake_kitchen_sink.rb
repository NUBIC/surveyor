require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'rake'

describe Surveyor::Parser do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/surveyor_tasks"
    Rake::Task.define_task(:environment)
  end
  it "should return properly parse the kitchen sink survey" do
    ENV["FILE"]="surveys/kitchen_sink_survey.rb"
    @rake["surveyor"].invoke

    Survey.count.should == 1
    SurveySection.count.should == 2
    Question.count.should == 44
    Answer.count.should == 241
    Dependency.count.should == 6
    DependencyCondition.count.should == 9
    QuestionGroup.count.should == 6

    Survey.all.map(&:destroy)
  end
  it "should return properly parse a UTF8 survey" do
    ENV["FILE"]="../spec/fixtures/chinese_survey.rb"
    @rake["surveyor"].invoke

    Survey.count.should == 1
    SurveySection.count.should == 1
    Question.count.should == 3
    Answer.count.should == 15
    Dependency.count.should == 0
    DependencyCondition.count.should == 0
    QuestionGroup.count.should == 1

    Survey.all.map(&:destroy)
  end

end