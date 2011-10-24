module Surveyor
  require 'surveyor/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3

  autoload :VERSION, 'surveyor/version'
end
require 'surveyor/common'
require 'surveyor/acts_as_response'
require 'formtastic/surveyor_builder'
# require 'surveyor/surveyor_controller_methods'
# require 'surveyor/models/survey_methods'
Formtastic::SemanticFormHelper.builder = Formtastic::SurveyorBuilder
Formtastic::SemanticFormBuilder.default_text_area_height = 5
Formtastic::SemanticFormBuilder.default_text_area_width = 50
Formtastic::SemanticFormBuilder.all_fields_required_by_default = false
