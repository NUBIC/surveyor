$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require File.expand_path(File.dirname(__FILE__) + "/../../../lib/surveyor")
require File.expand_path(File.dirname(__FILE__) + "/../parser")
require File.expand_path(File.dirname(__FILE__) + "/../base")

Spec::Runner.configure do |config|
end