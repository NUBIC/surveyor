source :rubygems

gemspec

eval(File.read File.expand_path('../Gemfile.rails_version', __FILE__))

group :development do
  # use git version for the ci:setup:rspecbase task; not there in
  # 1.6.5, but might be in a later version.
  gem 'ci_reporter', :git => 'git://github.com/nicksieger/ci_reporter.git'
end
