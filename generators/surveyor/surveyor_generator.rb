class SurveyorGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      
      # Migrate 
      # not using m.migration_template because all migration timestamps end up the same, causing a collision when running rake db:migrate
      # coped functionality from RAILS_GEM_PATH/lib/rails_generator/commands.rb
      m.directory "db/migrate"
      ["surveys", "survey_sections", "questions", "answers", "response_sets", "responses", "dependencies", "question_groups", "dependency_conditions"].each_with_index do |model, i|
        raise "Another migration is already named #{migration_file_name}" if not Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_create_#{model}.rb$/).empty?
        m.template("migrate/create_#{model}.rb", "db/migrate/#{(Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + i).to_s}_create_#{model}.rb")
      end
      
      # Generate CSS
      root = File.join(File.dirname(__FILE__), "templates", "assets", "stylesheets")
      `sass #{root}/sass/surveyor.sass #{root}/surveyor.css`

      # Assets
      ["images", "javascripts", "stylesheets"].each do |asset_type|
        m.directory "public/#{asset_type}/surveyor"
        Dir.glob(File.join(File.dirname(__FILE__), "templates", "assets", asset_type, "*.*")).map{|path| File.basename(path)}.each do |filename|
          m.file "assets/#{asset_type}/#{filename}", "public/#{asset_type}/surveyor/#{filename}"
        end
      end
      
      # Surveys
      m.directory "surveys"
      m.directory "surveys/fixtures"
      m.file "surveys/kitchen_sink_survey.rb", "surveys/kitchen_sink_survey.rb"
      
      m.readme "README"
      
    end
  end
  def self.next_migration_string(i)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
end
