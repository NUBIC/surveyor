require 'rails'
require 'surveyor'
require 'surveyor/helpers/asset_pipeline'
require 'haml' # required for view resolution

module Surveyor
  class Engine < Rails::Engine
    root = File.expand_path('../../', __FILE__)

    config.autoload_paths << root

    initializer 'surveyor.asset_pipeline', :group => :all do |app|
      extend Surveyor::Helpers::AssetPipeline

      if asset_pipeline_enabled?
        app.config.assets.paths += Dir[
          "#{root}/generators/surveyor/templates/public/*",
          "#{root}/../app/assets/*"
        ]
      end
    end
  end
end
