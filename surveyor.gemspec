# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "surveyor/version"

Gem::Specification.new do |s|
  s.name = %q{surveyor}
  s.version = Surveyor::VERSION

  s.authors = ["Brian Chamberlain", "Mark Yoon"]
  s.email = %q{yoon@northwestern.edu}
  s.homepage = %q{http://github.com/NUBIC/surveyor}
  s.post_install_message = %q{Thanks for installing surveyor! The time has come to run the surveyor generator and migrate your database, even if you are upgrading.}
  s.summary = %q{A rails (gem) plugin to enable surveys in your application}

  s.files         = `git ls-files`.split("\n") - ['irb']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rails', '~> 3.0.0') # Issue 228
  s.add_dependency('haml')
  s.add_dependency('sass')
  s.add_dependency('fastercsv')
  s.add_dependency('formtastic')
  s.add_dependency('uuid')
  
  s.add_development_dependency('yard')
  s.add_development_dependency('rake', '0.8.7')
  s.add_development_dependency('rspec', '< 2')
  s.add_development_dependency('bundler', '~> 1.0')
end

