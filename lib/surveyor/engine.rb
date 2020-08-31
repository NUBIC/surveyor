require 'rails'
require 'surveyor'

module Surveyor
  class Engine < Rails::Engine
    root = File.expand_path('../../', __FILE__)
    config.autoload_paths << root
    config.to_prepare do
      Dir.glob(File.expand_path('../../../app/inputs/*_input*.rb', __FILE__)).each do |c|
        require_dependency(c)
      end
    end
    config.assets.precompile += %w( surveyor_all.css surveyor_all.js )

    initializer "surveyor.factories", :after => "factory_bot#.set_factory_paths" do
      FactoryBot.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__) if defined?(FactoryBot)
    end
  end
end
