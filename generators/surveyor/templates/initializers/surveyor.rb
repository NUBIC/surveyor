Surveyor::Config.run do |config|
  config['default.relative_url_root'] = nil # "surveys/"
  config['default.title'] = nil # "You can take these surveys:"
  config['default.layout'] = nil # "surveyor_default"
  config['default.finish'] =  nil # "/surveys" # or :finish_path_method # Proc.new{ generate_path }
end