require 'surveyor/common'
require 'surveyor/acts_as_response'


Dir.glob(File.join(File.dirname(__FILE__),'..','app','models','*.rb')).each{|f| require f}
Dir.glob(File.join(File.dirname(__FILE__),'..','app','helpers','*.rb')).each{|f| require f}