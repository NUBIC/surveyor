module Surveyor
  require 'surveyor/engine' if defined?(Rails) && Rails::VERSION::MAJOR >= 3
  autoload :VERSION, 'surveyor/version'
  autoload :ParserError, 'surveyor/parser'
end
require 'surveyor/common'
require 'surveyor/acts_as_response'
# require 'surveyor/surveyor_controller_methods'
# require 'surveyor/models/survey_methods'
require 'formtastic'
Formtastic::FormBuilder.default_text_area_height = 5
Formtastic::FormBuilder.default_text_area_width = 50
Formtastic::FormBuilder.all_fields_required_by_default = false
