ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec/autorun'
require 'spec/rails'

require File.dirname(__FILE__) + "/factories"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# require 'surveyor'

Spec::Runner.configure do |config|
  
end