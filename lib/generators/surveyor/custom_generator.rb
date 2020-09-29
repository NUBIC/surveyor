# encoding: UTF-8
# frozen_string_literal: true

require 'rails/generators'
module Surveyor
  class CustomGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def readme
      copy_file 'surveys/EXTENDING_SURVEYOR.md'
    end

    def controller
      copy_file 'app/controllers/surveyor_controller.rb'
    end

    def layout
      copy_file 'app/views/layouts/surveyor_custom.html.erb'
    end
  end
end
