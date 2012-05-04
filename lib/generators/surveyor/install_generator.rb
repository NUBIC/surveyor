require 'rails/generators'
module Surveyor
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)
    desc "Generate surveyor README, migrations, assets and sample survey"
    class_option :skip_migrations, :type => :boolean, :desc => "skip migrations, but generate everything else"

    def assets      
      # for Rails 3.0 or when asset pipeline is disabled
      if ::Rails.version < "3.1" || !::Rails.application.config.assets.enabled 
        
        say("Asset pipeline disabled. this generator will copy all assets to public directory")
        javascript_file_list = %w(jquery.tools.min.js jquery-ui.js jquery-ui-timepicker-addon.js jquery.surveyor.js jquery.blockUI.js)
        javascript_file_list.each do |f|
          copy_file "../../../../vendor/assets/javascripts/surveyor/#{f}", "public/javascripts/#{f}"
          say_status("copying","#{f}", :green)
        end
        #Todo: surveyor.sass & custom.sass do not work.
        stylesheet_file_list = %w(reset.css dateinput.css jquery-ui.custom.scss jquery-ui-timepicker-addon.css)
        stylesheet_file_list.each do |f|
          copy_file "../../../../vendor/assets/stylesheets/surveyor/#{f}", "public/stylesheets/#{f}"
          say_status("copying","#{f}", :green)
        end
        say("including stylesheets & javascripts into layout")
        insert_into_file "./../app/views/layouts/surveyor_default.html.erb","<%= stylesheet_link_tag #{stylesheet_file_list.map{|f| "'#{f}'"}.join(", ")}%>\n", :before => "</head>"
        insert_into_file "./../app/views/layouts/surveyor_default.html.erb","<%= javascript_include_tag #{javascript_file_list.map{|f| "'#{f}'"}.join(", ")}%>\n", :before => "</head>"
      
      # for Rails 3.1 & great with asset pile enabled
      else 
        #require javascripts into app
        if File.exist?('app/assets/javascripts/application.js')
            insert_into_file "app/assets/javascripts/application.js", "//= require surveyor\n", :after => "jquery\n"
        end

        #require css into app
        if File.exist?('app/assets/stylesheets/application.css')          
            insert_into_file "app/assets/stylesheets/application.css", " *= require surveyor.scss\n", :after => "require_self\n"
        end

        #now, lets add javascript_include_tag & stylesheet_link_tag
        say("including stylesheets & javascripts into layout")
          insert_into_file "./../app/views/layouts/surveyor_default.html.erb","<%= stylesheet_link_tag ('application') :media => 'all' %>\n", :before => "</head>"
          insert_into_file "./../app/views/layouts/surveyor_default.html.erb","<%= javascript_include_tag ('application')%>\n", :before => "</head>"  
      end
    end

    def readme
      copy_file "../../../../README.md", "surveys/README.md"
    end
    def migrations
      unless options[:skip_migrations]
        # because all migration timestamps end up the same, causing a collision when running rake db:migrate
        # copied functionality from RAILS_GEM_PATH/lib/rails_generator/commands.rb
        %w(create_surveys create_survey_sections create_questions create_question_groups create_answers create_response_sets create_responses create_dependencies create_dependency_conditions create_validations create_validation_conditions add_display_order_to_surveys add_correct_answer_id_to_questions add_index_to_response_sets add_index_to_surveys add_unique_indicies add_section_id_to_responses add_default_value_to_answers add_api_ids add_display_type_to_answers add_api_id_to_question_groups add_api_ids_to_response_sets_and_responses update_blank_api_ids_on_question_group).each_with_index do |model, i|
          unless (prev_migrations = Dir.glob("db/migrate/[0-9]*_*.rb").grep(/[0-9]+_#{model}.rb$/)).empty?
            prev_migration_timestamp = prev_migrations[0].match(/([0-9]+)_#{model}.rb$/)[1]
          end
          copy_file("db/migrate/#{model}.rb", "db/migrate/#{(prev_migration_timestamp || Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + i).to_s}_#{model}.rb")
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
