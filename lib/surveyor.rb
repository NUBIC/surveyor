dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'surveyor/config'
require 'surveyor/acts_as_response'

module Surveyor
end