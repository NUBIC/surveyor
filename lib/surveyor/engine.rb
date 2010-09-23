require 'rails'
require 'surveyor'

module Surveyor
  class Engine < Rails::Engine
    engine_name :surveyor
    rake_tasks do
      load "lib/tasks/surveyor_tasks.rake"
    end
  end
end
