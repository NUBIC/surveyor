require 'rails/generators'
module Surveyor
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    
    # Copy README to your app
    def readme
      copy_file "../../../README.md", "surveys/README.md"
    end
    
    # Migrations
    def migrations      
      # Migrate 
      # because all migration timestamps end up the same, causing a collision when running rake db:migrate
      # coped functionality from RAILS_GEM_PATH/lib/rails_generator/commands.rb
      %w(create_surveys create_survey_sections create_questions create_question_groups create_answers create_response_sets create_responses create_dependencies create_dependency_conditions create_validations create_validation_conditions add_display_order_to_surveys add_correct_answer_id_to_questions add_index_to_response_sets add_index_to_surveys add_unique_indicies).each_with_index do |model, i|
        unless (prev_migrations = Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_#{model}.rb$/)).empty?
          prev_migration_timestamp = prev_migrations[0].match(/([0-9]+)_#{model}.rb$/)[1]
        end
        copy_file("db/migrate/#{model}.rb", "db/migrate/#{(prev_migration_timestamp || Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + i).to_s}_#{model}.rb")
      end
    end
    
    # Generate CSS
    def sass_to_css
      css_root = File.join(File.dirname(__FILE__), "templates", "public", "stylesheets", "surveyor")
      `sass #{css_root}/sass/surveyor.sass #{css_root}/surveyor.css`
    end
    
    # Assets
    def assets
      directory "public"
    end
    
    # Surveys
    def surveys
      create_file "surveys/fixtures/.gitkeep"
      copy_file "surveys/kitchen_sink_survey.rb"
    end
    
    # Taken from ActiveRecord's migration generator
    def self.next_migration_number(dirname) #:nodoc:
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end
  end
end