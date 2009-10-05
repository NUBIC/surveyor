Surveyor::Config.run do |config|
  config['default.relative_url_root'] = nil # "surveys/" # should end with '/'
  config['default.title'] = nil # "You can take these surveys:"
  config['default.layout'] = nil # "surveyor_default"
  config['default.finish'] =  nil # "/surveys" # or :finish_path_method
  config['use_restful_authentication'] = false # set to true to use restful authentication
  config['extend_controller'] = false # set to true to extend SurveyorController
end

# require 'models/survey_extensions' # Extended the survey model
# require 'helpers/surveyor_helper_extensions' # Extend the surveyor helper