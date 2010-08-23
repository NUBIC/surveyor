class ExtendSurveyorGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      
      # Copy README to your app
      m.file "EXTENDING_SURVEYOR", "surveys/EXTENDING_SURVEYOR"
          
      # Custom layout
      m.directory "app/views/layouts"
      m.file "extensions/surveyor_custom.html.erb", "app/views/layouts/surveyor_custom.html.erb"
      
      # Model, helper, and controller extensions
      # http://www.redmine.org/boards/3/topics/4095#message-4136
      # http://blog.mattwynne.net/2009/07/11/rails-tip-use-polymorphism-to-extend-your-controllers-at-runtime/
      m.file "extensions/surveyor_controller.rb", "app/controllers/surveyor_controller.rb"
      
      m.readme "EXTENDING_SURVEYOR"
      
    end
  end
end
