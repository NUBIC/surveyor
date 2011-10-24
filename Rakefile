$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

task :default => :spec

namespace :cucumber do
  Cucumber::Rake::Task.new(:ok, 'Run features that should pass') do |t|
    t.profile = 'default'
  end

  Cucumber::Rake::Task.new(:wip, 'Run features that are being worked on') do |t|
    t.profile = 'wip'
  end

  desc 'Run all features'
  task :all => [:ok, :wip]
end
desc 'Alias for cucumber:ok'
task :cucumber => 'cucumber:ok'