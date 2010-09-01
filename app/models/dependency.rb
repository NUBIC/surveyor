class Dependency < ActiveRecord::Base
  unloadable
  include Surveyor::Models::DependencyMethods
end
