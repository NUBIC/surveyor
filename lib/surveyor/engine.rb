require 'rails'
require 'surveyor'

module Surveyor
  class Engine < Rails::Engine
    rake_tasks do
      load "tasks/surveyor_tasks.rake"
    end
  end
end
