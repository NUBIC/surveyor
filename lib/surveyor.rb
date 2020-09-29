# frozen_string_literal: true

module Surveyor
  require 'surveyor/engine' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
  autoload :VERSION, 'surveyor/version'
  autoload :ParserError, 'surveyor/parser'
end
require 'surveyor/common'
require 'surveyor/acts_as_response'
# require 'surveyor/surveyor_controller_methods'
# require 'surveyor/models/survey_methods'
