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

  s.add_dependency('rails', '~> 3.0')
  # '< 5.0' is to be conservative; once 5.0 comes out we should test with it and
  # allow it if it works.
  s.add_dependency('haml', '>= 3.1.3', '< 5.0')
  s.add_dependency('sass')
  s.add_dependency('fastercsv', '~> 1.5.4')
  s.add_dependency('formtastic', '~> 2.1.0')
  s.add_dependency('uuidtools', '~> 2.1')
  s.add_dependency('mustache', '0.99.4')
  s.add_dependency('rabl', '~>0.6.13')

  s.add_development_dependency('yard')
  s.add_development_dependency('rake', '>= 0.9.2')
  s.add_development_dependency('rspec-rails', '~> 2.9.0')
  s.add_development_dependency('bundler', '~> 1.0', '>= 1.0.21')
  s.add_development_dependency('factory_girl', '~> 2.1.2')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('cucumber-rails', '~> 1.1.1')
  s.add_development_dependency('database_cleaner', '~> 0.6.7')
  s.add_development_dependency('launchy', '~> 2.0.5')
  s.add_development_dependency('capybara', '~> 1.1.1')
  s.add_development_dependency('ci_reporter', '1.6.6')
  s.add_development_dependency('json_spec', '~> 1.0.3')
end

