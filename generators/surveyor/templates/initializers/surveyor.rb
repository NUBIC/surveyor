Surveyor::Config.run do |config|
  config['default.relative_url_root'] = nil # "surveys/" # should end with '/'
  config['default.title'] = nil # "You can take these surveys:"
  config['default.layout'] = nil # "surveyor_default"
  config['default.finish'] =  nil # "/surveys" # or :finish_path_method
  config['use_restful_authentication'] = false
end