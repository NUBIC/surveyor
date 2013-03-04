# encoding: UTF-8
require 'rails/generators'
require 'surveyor/helpers/asset_pipeline'

module Surveyor
  class InstallGenerator < Rails::Generators::Base
    include Surveyor::Helpers::AssetPipeline

    source_root File.expand_path("../templates", __FILE__)
    desc "Generate surveyor README, migrations, assets and sample survey"
    class_option :skip_migrations, :type => :boolean, :desc => "skip migrations, but generate everything else"

    MIGRATION_ORDER = %w(
      create_surveys
      create_survey_sections
      create_questions
      create_question_groups create_answers
      create_response_sets
      create_responses
      create_dependencies
      create_dependency_conditions
      create_validations
      create_validation_conditions
      add_display_order_to_surveys
      add_correct_answer_id_to_questions
      add_index_to_response_sets
      add_index_to_surveys
      add_unique_indicies
      add_section_id_to_responses
      add_default_value_to_answers
      add_api_ids
      add_display_type_to_answers
      add_api_id_to_question_groups
      add_api_ids_to_response_sets_and_responses
      update_blank_api_ids_on_question_group
      drop_unique_index_on_access_code_in_surveys
      add_version_to_surveys
      add_unique_index_on_access_code_and_version_in_surveys
      update_blank_versions_on_surveys
      api_ids_must_be_unique
      create_survey_translations
    )

    def readme
      copy_file "../../../../README.md", "surveys/README.md"
    end
    def migrations
      unless options[:skip_migrations]
        migration_files = Dir[File.join(self.class.source_root, 'db/migrate/*.rb')]
        migrations_not_in_order =
          migration_files.collect { |f| File.basename(f).sub(/\.rb$/, '') } - MIGRATION_ORDER
        unless migrations_not_in_order.empty?
          fail "%s migration%s not added to MIGRATION_ORDER: %s" % [
            migrations_not_in_order.size,
            migrations_not_in_order.size == 1 ? '' : 's',
            migrations_not_in_order.join(', ')
          ]
        end

        # because all migration timestamps end up the same, causing a collision when running rake db:migrate
        # copied functionality from RAILS_GEM_PATH/lib/rails_generator/commands.rb
        MIGRATION_ORDER.each_with_index do |model, i|
          unless (prev_migrations = Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_#{model}.rb$/)).empty?
            prev_migration_timestamp = prev_migrations[0].match(/([0-9]+)_#{model}.rb$/)[1]
          end
          copy_file("db/migrate/#{model}.rb", "db/migrate/#{(prev_migration_timestamp || Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + i).to_s}_#{model}.rb")
        end
      end
    end

    def assets
      if asset_pipeline_enabled?
        directory "app/assets"
        copy_file "vendor/assets/stylesheets/custom.sass"
      else
        directory "../../../assets/javascripts", "public/javascripts"
        directory "../../../assets/images", "public/images"
        directory "../../../assets/stylesheets/surveyor", "public/stylesheets/surveyor"
        copy_file "../../../assets/stylesheets/surveyor.sass", "public/stylesheets/sass/surveyor.sass"
        copy_file "vendor/assets/stylesheets/custom.sass", "public/stylesheets/sass/custom.sass"
      end
    end

    def surveys
      copy_file "surveys/kitchen_sink_survey.rb"
      copy_file "surveys/quiz.rb"
      copy_file "surveys/date_survey.rb"
      copy_file "surveys/languages.rb"
      directory "surveys/translations"
    end

    def locales
      directory "config/locales"
    end
  end
end
