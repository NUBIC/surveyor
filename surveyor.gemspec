# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'surveyor/version'

Gem::Specification.new do |s|
  s.name = 'surveyor'
  s.version = Surveyor::VERSION

  s.authors = ['Brian Chamberlain', 'Mark Yoon', 'User Interviews, Inc']
  s.homepage = 'http://github.com/user-interviews/surveyor'
  s.post_install_message = 'Thanks for using surveyor! Remember to run the surveyor generator and migrate your database, even if you are upgrading.'
  s.summary = 'A rails (gem) plugin to enable surveys in your application'

  s.files         = `git ls-files`.split("\n") - ['irb']
  s.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency('mustache', '~> 1.1.1')
  s.add_dependency('rails', '>= 5.2.6')
  s.add_dependency('uuidtools', '~> 2.2.0')

  s.add_development_dependency('bootsnap', '~> 1.7.6')
  s.add_development_dependency('bundler', '~> 2.2.23')
  s.add_development_dependency('capybara', '~> 3.35.3')
  s.add_development_dependency('database_cleaner', '~> 2.0.1')
  s.add_development_dependency('factory_bot', '~> 6.2.0')
  s.add_development_dependency('json_spec', '~> 1.1.5')
  s.add_development_dependency('launchy', '~> 2.5.0')
  s.add_development_dependency('poltergeist', '~>1.18.1')
  s.add_development_dependency('rake', '~> 13.0.6')
  s.add_development_dependency('rspec-collection_matchers')
  s.add_development_dependency('rspec-rails', '~> 5.0.1')
  s.add_development_dependency('rspec-retry', '~> 0.6.2')
  s.add_development_dependency('sprockets', '~> 4.0.2')
  s.add_development_dependency('sprockets-rails', '~> 3.2.2')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('yard')
end
