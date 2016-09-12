require 'rails'
require 'surveyor'
require 'simple_form'
require 'bootstrap-sass'
require 'haml' # required for view resolution

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

    initializer "surveyor.factories", :after => "factory_girl#.set_factory_paths" do
      FactoryGirl.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__) if defined?(FactoryGirl)
    end
  end
end
