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
    gem.add_dependency 'sass'
    gem.add_dependency 'fastercsv'
    gem.add_dependency 'formtastic'
    gem.add_dependency 'uuid'
    gem.add_development_dependency "yard", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
