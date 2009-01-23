require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

load File.dirname(__FILE__) + '/lib/tasks/surveyor_tasks.rake'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the surveyor plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the surveyor plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SurveyEngine'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
