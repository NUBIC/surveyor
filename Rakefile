require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "surveyor"
    gem.summary = %Q{A rails (gem) plugin to enable surveys in your application}
    gem.email = "yoon@northwestern.edu"
    gem.homepage = "http://github.com/breakpointer/surveyor"
    gem.authors = ["Brian Chamberlain", "Mark Yoon"]
    gem.add_dependency 'haml'
    gem.add_dependency 'fastercsv'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

desc "Set up a rails app for testing in the spec dir"
task :testbed => [:"testbed:build_app", :"testbed:copy_files", :"testbed:install_surveyor"]

namespace "testbed" do
  RAPPNAME = "test_app" #This is also hardcoded in the spec/spec_helper.rb and gitignore file. Change it there too...
  
  "Generate rails app in spec dir"
  task :build_app do
    directory "spec"
    chdir("spec") do
      sh "rails #{RAPPNAME}"
      puts "Put a test_app in the spec folder"
      chdir("#{RAPPNAME}") do
        sh "ruby script/generate rspec"
        puts "Ran installer for rspec in #{RAPPNAME}"
        sh "ruby script/generate cucumber --webrat"
        puts "Ran installer for cucumber in #{RAPPNAME}"
      end
    end
  end
 
  desc "Copy in setup files to test app"
  task :copy_files do
    chdir("spec/#{RAPPNAME}") do
      sh "cp ../test_Gemfile Gemfile"
      sh "cp ../test_preinitializer.rb config/preinitializer.rb"
      sh "cp ../test_boot.rb config/boot.rb"
      puts "NOTE: These files were created/modified as described here: http://gembundler.com/rails23.html"
    end
  end

  desc "Install surveyor in test app, run migrations, prep test db"
  task :install_surveyor do
    sh "gem install surveyor"
    chdir("spec/#{RAPPNAME}") do
      sh "bundle install"
      sh "bundle exec script/generate surveyor"
      sh "rake db:migrate"
      sh "rake db:test:prepare"
    end
    # I don't think this is needed anymore
    puts "NOTE: We installed the surveyor gem using 'gem install surveyor' to fix a problem where RVM (or bundler or both) don't let Rails see generators in a gem. ('script/generate surveyor' for example). To remove the gem run `gem uninstall surveyor` to remove the gem version of surveyor leaving the dev version" # Getting around a bug/problem in bundler. see: http://bit.ly/9NZOEz
  end

  desc "Remove rails test app from spec dir"
  task :remove do
    puts "Removing the test_app in the spec folder"
    sh "rm -rf spec/#{RAPPNAME}"
  end
end # namespace

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList.new('spec/**/*_spec.rb') do |fl|
    fl.exclude(/vendor\/plugins/) #excluding the stuff inthe embedded rails app
    fl.exclude(/unparse/) #not sure why but this breaks a bunch of specs
  end
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "surveyor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

