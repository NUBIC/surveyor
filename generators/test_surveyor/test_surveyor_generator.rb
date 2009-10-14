class TestSurveyorGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      
      m.directory "surveys"
      
      # Copy README to your app
      m.file "TESTING_SURVEYOR", "surveys/TESTING_SURVEYOR"
        
      m.file "environments/cucumber.rb", "config/environments/cucumber.rb"
      m.readme "TESTING_SURVEYOR"
      
    end
  end
end
