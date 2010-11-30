
require 'rubygems'
require 'bundler'
Bundler.setup

require "spec"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)


this_dir = File.dirname(__FILE__)
raise "Alert! Run the rake task to install the test Rails app. It seems to be missing." unless File.directory?(File.join(this_dir,'test_app/spec'))
require File.join(this_dir, 'test_app/spec/spec_helper')
require File.join(this_dir, '/factories')

require 'surveyor'
require 'surveyor/parser'

Spec::Runner.configure do |config|
end
