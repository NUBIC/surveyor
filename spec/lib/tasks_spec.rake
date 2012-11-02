require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "rake"

describe "app rake tasks" do
  before(:all) do # do this only once before all tests
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/surveyor_tasks"
    Rake::Task.define_task(:environment)
  end
  after do # after every test
    @rake[@task_name].reenable if @task_name
  end

  it "should have 'environment' as a prereq" do
    @task_name = "surveyor:parse"
    @rake[@task_name].prerequisites.should include("environment")
  end
  it "should should trace" do
    ENV["FILE"]="surveys/kitchen_sink_survey.rb"
    @task_name = "surveyor:parse"
    @rake.options.trace = true
    Surveyor::Parser.should_receive(:parse).with(File.read(File.join(Rails.root, ENV["FILE"])), {:trace => true})
    @rake[@task_name].invoke
  end
end