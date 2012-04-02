require 'rails/generators'
module Surveyor
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    desc "Generate surveyor README, migrations, assets and sample survey"
    class_option :skip_migrations, :type => :boolean, :desc => "skip migrations, but generate everything else"

    def readme
      copy_file "../../../../README.md", "surveys/README.md"
    end
    def migrations
      unless options[:skip_migrations]
        # because all migration timestamps end up the same, causing a collision when running rake db:migrate
        # copied functionality from RAILS_GEM_PATH/lib/rails_generator/commands.rb
        %w(create_surveys create_survey_sections create_questions create_question_groups create_answers create_response_sets create_responses create_dependencies create_dependency_conditions create_validations create_validation_conditions add_display_order_to_surveys add_correct_answer_id_to_questions add_index_to_response_sets add_index_to_surveys add_unique_indicies add_section_id_to_responses add_default_value_to_answers add_api_ids add_display_type_to_answers add_api_id_to_question_groups).each_with_index do |model, i|
          unless (prev_migrations = Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_#{model}.rb$/)).empty?
            prev_migration_timestamp = prev_migrations[0].match(/([0-9]+)_#{model}.rb$/)[1]
          end
          copy_file("db/migrate/#{model}.rb", "db/migrate/#{(prev_migration_timestamp || Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + i).to_s}_#{model}.rb")
        end
      end
    end
    def assets
      asset_directory = "public"
      if Rails.application.config.respond_to?(:assets) && Rails.application.config.assets.enabled == true
        asset_directory = "vendor/assets"
      end
      %w( templates/public/images/surveyor templates/public/javascripts/surveyor templates/public/stylesheets/surveyor templates/public/stylesheets/sass ).each do |path|
        asset_path = File.expand_path("../#{path}", __FILE__)
        Dir.foreach(asset_path) do |f|
          next if File.directory?(f)

          from_path = "#{path.gsub('templates/public', 'public')}/#{f}"
          to_path = "#{path.gsub('templates/public', asset_directory)}/#{f}"
          to_path = to_path.gsub("/sass", "") if asset_directory == "vendor/assets"
          copy_file(from_path, to_path)
        end
      end

    end
    def surveys
      copy_file "surveys/kitchen_sink_survey.rb"
      copy_file "surveys/quiz.rb"
      copy_file "surveys/date_survey.rb"
    end
    def locales
      directory "config/locales"
    end

  end
end
