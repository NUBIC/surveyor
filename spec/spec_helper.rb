
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

require 'spec'
require 'spec/rails'

# class Test::Unit::TestCase
#   class << self
#     # Class method for test helpers
#     def test_helper(*names)
#       names.each do |name|
#         name = name.to_s
#         name = $1 if name =~ /^(.*?)_test_helper$/i
#         name = name.singularize
#         first_time = true
#         begin
#           constant = (name.camelize + 'TestHelper').constantize
#           self.class_eval { include constant }
#         rescue NameError
#           filename = File.expand_path(SPEC_ROOT + '/../test/helpers/' + name + '_test_helper.rb')
#           require filename if first_time
#           first_time = false
#           retry
#         end
#       end
#     end    
#     alias :test_helpers :test_helper
#   end
# end
# 

# Spec::Runner.configure do |config|
#   # If you're not using ActiveRecord you should remove these
#   # lines, delete config/database.yml and disable :active_record
#   # in your config/boot.rb
#   config.use_transactional_fixtures = true
#   config.use_instantiated_fixtures  = false
#   config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
# 
#   # == Fixtures
#   #
#   # You can declare fixtures for each example_group like this:
#   #   describe "...." do
#   #     fixtures :table_a, :table_b
#   #
#   # Alternatively, if you prefer to declare them only once, you can
#   # do so right here. Just uncomment the next line and replace the fixture
#   # names with your fixtures.
#   #
#   # config.global_fixtures = :table_a, :table_b
#   #
#   # If you declare global fixtures, be aware that they will be declared
#   # for all of your examples, even those that don't use them.
#   #
#   # You can also declare which fixtures to use (for example fixtures for test/fixtures):
#   #
#   # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
#   #
#   # == Mock Framework
#   #
#   # RSpec uses it's own mocking framework by default. If you prefer to
#   # use mocha, flexmock or RR, uncomment the appropriate line:
#   #
#   # config.mock_with :mocha
#   # config.mock_with :flexmock
#   # config.mock_with :rr
#   #
#   # == Notes
#   # 
#   # For more information take a look at Spec::Example::Configuration and Spec::Runner
# end
