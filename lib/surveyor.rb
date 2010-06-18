require 'surveyor/acts_as_response'

module Surveyor
  require 'surveyor/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
end