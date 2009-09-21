class SurveyorGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      
      # Migrate
      ["surveys", "survey_sections", "questions", "answers", "response_sets", "responses", "dependencies", "question_groups", "dependency_conditions"].each do |model|
        m.migration_template "migrate/create_#{model}.rb", 'db/migrate', :migration_file_name => "create_#{model}"
      end
      
      # Generate CSS
      root = File.join(File.dirname(__FILE__), "templates", "stylesheets")
      `sass #{root}/sass/surveyor.sass #{root}/surveyor.css`

      # Assets
      ["images", "javascripts", "stylesheets"].each do |asset_type|
        m.directory "public/#{asset_type}/surveyor"
        Dir.glob(File.join("assets", asset_type, "*")).each do |filename|
          m.file "assets/#{asset_type}/#{filename}", "public/#{asset_type}/surveyor/#{filename}"
        end
      end
      
      # Surveys
      m.directory "surveys"
      m.directory "surveys/fixtures"
      m.file "surveys/kitchen_sink_survey.rb", "surveys/kitchen_sink_survey.rb"
      
      m.readme "../../../README.md"
      
    end
  end
end