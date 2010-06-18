require 'generators/install_generator.rb'
require 'generators/custom_generator.rb'
require 'surveyor/acts_as_response'

module Surveyor
  require 'surveyor/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  # Tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load "lib/tasks/surveyor_tasks.rake"
    end
  end
end

# From http://guides.rubyonrails.org/plugins.html#controllers
# Fix for:
# ArgumentError in SurveyorController#edit 
# A copy of ApplicationController has been removed from the module tree but is still active!
# Equivalent of using "unloadable" in SurveyorController (unloadable has been deprecated)

# %w{models controllers}.each do |dir|
#   path = File.expand_path(File.join(File.dirname(__FILE__), '../app', dir))
#   # $LOAD_PATH << path # already here
#   # ActiveSupport::Dependencies.load_paths << path # already here too
#   ActiveSupport::Dependencies.load_once_paths.delete(path)
#   # [$LOAD_PATH, ActiveSupport::Dependencies.load_paths, ActiveSupport::Dependencies.load_once_paths].each{|x| Rails.logger.info x}
# end
