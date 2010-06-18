require 'rails/generators'
module Surveyor
  class CustomGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    # Controller
    def initializer
      copy_file "app/controllers/surveyor_controller.rb"
    end
    
    def readme
      copy_file "README_FOR_CUSTOM_SURVEYOR", "surveys/README_FOR_CUSTOM_SURVEYOR"
    end
  end
end