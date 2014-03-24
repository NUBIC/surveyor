module Surveyor
  module Helpers
    module AssetPipeline
      ##
      # Returns whether or not the asset pipeline is present and enabled.
      #
      # With Rails4 it appears that assets.enabled is false if
      # --skip-sprockets is specified when creating the application,
      # but the assets.enabled option is nil in the default case
      # (i.e., pipeline enabled).
      def asset_pipeline_enabled?
        return false unless Rails.configuration.respond_to?('assets')
        assets = Rails.configuration.assets
        assets.enabled.nil? || assets.enabled
      end
    end
  end
end
