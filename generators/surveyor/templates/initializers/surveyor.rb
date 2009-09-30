Surveyor::Config.run do |config|
  config['default.title'] = nil # "You can take these surveys:"
  config['default.layout'] = nil # "surveyor_default"
  config['default.finish'] = Proc.new{ "/surveys" }
end