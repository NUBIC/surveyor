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

namespace "testbed" do

  RAPPNAME = "test_app" #This is also hardcoded in the spec/spec_helper.rb and gitignore file. Change it there too...

  desc "Install rails base app in spec dir"
  task :build_app do
    directory "spec"
    chdir("spec") do
      sh "rails #{RAPPNAME}"
      puts "Put a test_app in the spec folder"
      chdir("#{RAPPNAME}") do
        sh "ruby script/generate rspec"
        puts "Ran plugin installer for rspec in #{RAPPNAME}"
      end
    end
  end
 
  desc "Copy in setup files to test app"
  task :copy_files do
    chdir("spec/#{RAPPNAME}") do
      sh "cp ../test_Gemfile Gemfile"
      sh "cp ../test_preinitializer.rb config/preinitializer.rb"
      puts "NOTE: Don't forget to modify the config/boot.rb file as described here: http://gembundler.com/rails23.html"
    end
  end

  desc "Install surveyor in rails base app, runs migrations, preps for testing"
  task :install_surveyor do
    sh "gem install surveyor"
    chdir("spec/#{RAPPNAME}") do
      sh "bundle install"
      sh "bundle exec script/generate surveyor"
      sh "rake db:migrate"
      sh "rake db:test:prepare"
    end
    puts "NOTE: Run `gem uninstall surveyor` to remove the gem version of surveyor leaving the dev version" # Getting around a bug/problem in bundler. see: http://bit.ly/9NZOEz
  end

  desc "Remove rails base app in spec dir"
  task :remove_app do
    puts "Removing the test_app in the spec folder"
    sh "rm -rf spec/#{RAPPNAME}"
  end

  desc "Setup for the test app (create)"
  task :setup => [:build_app, :copy_files, :install_surveyor]
  desc "Teardown for the test app (remove)"
  task :teardown => [:remove_app]

end # namespace

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
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

