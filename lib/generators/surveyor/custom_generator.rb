require 'rails/generators'
module Surveyor
  class CustomGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    def readme
      copy_file "surveys/README_FOR_CUSTOM_SURVEYOR.md"
    end
    def controller
      copy_file "app/controllers/surveyor_controller.rb"
    end
    def layout
      copy_file "app/views/layout/surveyor_custom.html.erb"
    end
    
  end
end