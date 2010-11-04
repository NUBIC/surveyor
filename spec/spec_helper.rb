
require 'rubygems'
require 'bundler'
Bundler.setup

require "spec"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require File.join(File.dirname(__FILE__), 'test_app/spec/spec_helper')
require File.dirname(__FILE__) + "/factories"

require 'surveyor'
require 'surveyor/parser'

Spec::Runner.configure do |config|
end
