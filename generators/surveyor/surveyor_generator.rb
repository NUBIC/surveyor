class SurveyorGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      
      m.directory "surveys"
      
      # Copy README to your app
      # m.file "../../../README.md", "surveys/README.md"
          
      # Gem plugin rake tasks
      m.file "tasks/surveyor.rb", "lib/tasks/surveyor.rb"
      if file_has_line(destination_path('Rakefile'), /^require 'tasks\/surveyor'$/ )
        logger.skipped 'Rakefile'
      else
        File.open(destination_path('Rakefile'), 'ab') {|file| file.write("\nrequire 'tasks/surveyor'\n") }
        # http://ggr.com/how-to-include-a-gems-rake-tasks-in-your-rails-app.html
        logger.appended 'Rakefile'
      end
      
      # Migrate 
      # not using m.migration_template because all migration timestamps end up the same, causing a collision when running rake db:migrate
      # coped functionality from RAILS_GEM_PATH/lib/rails_generator/commands.rb
      m.directory "db/migrate"
      [ "create_surveys", "create_survey_sections", "create_questions", "create_question_groups", "create_answers", 
        "create_response_sets", "create_responses", 
        "create_dependencies", "create_dependency_conditions", 
        "create_validations", "create_validation_conditions", 
        "add_display_order_to_surveys", "add_correct_answer_id_to_questions",
        "add_index_to_response_sets", "add_index_to_surveys", 
        "add_unique_indicies", "add_section_id_to_responses",
        "add_default_value_to_answers"].each_with_index do |model, i|
        unless (prev_migrations = Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_#{model}.rb$/)).empty?
          prev_migration_timestamp = prev_migrations[0].match(/([0-9]+)_#{model}.rb$/)[1]
        end
        # raise "Another migration is already named #{model}" if not Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_#{model}.rb$/).empty?
        m.template("migrate/#{model}.rb", "db/migrate/#{(prev_migration_timestamp || Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + i).to_s}_#{model}.rb")
      end
      
      # Assets
      ["images", "javascripts", "stylesheets"].each do |asset_type|
        m.directory "public/#{asset_type}/surveyor"
        Dir.glob(File.join(File.dirname(__FILE__), "templates", "assets", asset_type, "*.*")).map{|path| File.basename(path)}.each do |filename|
          m.file "assets/#{asset_type}/#{filename}", "public/#{asset_type}/surveyor/#{filename}"
        end
      end
      m.directory "public/stylesheets/sass"
      m.file "assets/stylesheets/sass/surveyor.sass", "public/stylesheets/sass/surveyor.sass"
      

      # Locales
      m.directory "config/locales"
      Dir.glob(File.join(File.dirname(__FILE__), "templates", "locales", "*.yml")).map{|path| File.basename(path)}.each do |filename|
        m.file "locales/#{filename}", "config/locales/#{filename}"
      end
      
      # Surveys
      m.directory "surveys/fixtures"
      m.file "surveys/kitchen_sink_survey.rb", "surveys/kitchen_sink_survey.rb"
      
      m.readme "README"
      
    end
  end
  def file_has_line(filename, rxp)
    File.readlines(filename).each{ |line| return true if line =~ rxp }
    false
  end
end
