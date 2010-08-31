require 'surveyor/common'
require 'surveyor/acts_as_response'

Dir.glob('app/models/*.rb').each{|f| require f}
Dir.glob('app/helpers/*.rb').each{|f| require f}