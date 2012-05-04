$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'ci/reporter/rake/rspec'

###### RSPEC

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

task :default => :spec

###### CUCUMBER

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

###### TESTBED

desc 'Set up the rails app that the specs and features use'
task :testbed => 'testbed:rebuild'

namespace :testbed do
  desc 'Generate a minimal surveyor-using rails app'
  task :generate do
    sh 'bundle exec rails new testbed'
    chdir('testbed') do
      gems = File.read('Gemfile')
      gems.sub!(/gem.*rails.*$/, '')

      unless gems =~ /gem.*sqlite3/
        gems += %Q{gem 'sqlite'\n}
      end

      unless gems =~ /gem.*jquery-rails/
        gems += %Q{gem 'jquery-rails'\n}
      end

      gems += %q{
plugin_root = File.expand_path('../..', __FILE__)
eval(File.read(File.join(plugin_root, 'Gemfile.rails_version')))
gem 'surveyor', :path => plugin_root
      }

      File.open('Gemfile', 'w') { |f| f.write(gems) }

      Bundler.with_clean_env do
        sh 'bundle update'
      end
    end
  end

  desc 'Prepare the databases for the testbed'
  task :migrate do
    chdir('testbed') do
      Bundler.with_clean_env do
        sh 'bundle exec rails generate surveyor:install'
        sh 'bundle exec rake db:migrate db:test:prepare'
      end
    end
  end

  desc 'Remove the testbed entirely'
  task :remove do
    rm_rf 'testbed'
  end

  task :rebuild => [:remove, :generate, :migrate]
end

###### CI

namespace :ci do
  task :all => ['rake:testbed', :spec, :cucumber, 'cucumber:wip']

  task :env do
    ENV['CI_REPORTS'] = 'reports/spec-xml'
    ENV['SPEC_OPTS'] = "#{ENV['SPEC_OPTS']} --format nested"
  end

  Cucumber::Rake::Task.new(:cucumber, 'Run features using the CI profile') do |t|
    t.profile = 'ci'
  end

  Cucumber::Rake::Task.new('cucumber:wip', 'Run WIP features using the CI profile') do |t|
    t.profile = 'ci_wip'
  end

  task :spec => [:env, 'ci:setup:rspecbase', 'rake:spec']
end
