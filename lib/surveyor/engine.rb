require 'rails'
require 'surveyor'
require 'haml' # required for view resolution

module Surveyor
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("../../", __FILE__)
    # rake_tasks do
    #   load "tasks/surveyor_tasks.rake"
    # end
  end
end
