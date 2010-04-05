# Loaded once. Restart your app (even in development) to apply changes made here
Surveyor::Config.run do |config|
  config['default.relative_url_root'] = nil # "surveys"
  config['default.title'] = nil # "You can take these surveys:"
  config['default.layout'] = nil # "surveyor_default"
  config['default.index'] =  nil # "/surveys" # or :index_path_method
  config['default.finish'] =  nil # "/surveys" # or :finish_path_method
  config['use_restful_authentication'] = false # set to true to use restful authentication
  config['extend'] = %w() # %w(survey surveyor_helper surveyor_controller)
end