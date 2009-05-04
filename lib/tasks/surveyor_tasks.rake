
# location of plugin
SURVEYOR_ROOT = File.join(RAILS_ROOT, "vendor/plugins/surveyor")
require SURVEYOR_ROOT + '/script/survey_dsl/dslparse'
require 'active_record/fixtures'
require 'fileutils'

namespace :survey_dsl do

  desc  'Runs DSL, copies fixtures, deletes content in tables, loads fixtures (equiv to :generate, :copy_fixtures, :load in that sequence)'
  task :bootstrap => [ 'survey_dsl:generate', 'survey_dsl:copy_fixtures', 'survey_dsl:load' ]
  
  desc "Run the DSL on a specific file"
  task :generate do
    unless ENV["FILE"].blank?
      DSLParse.parse(File.join(RAILS_ROOT, ENV["FILE"]))
    else
      raise "filename (relative to Rails Root) needed 'FILE=vendor/plugins/surveyor/blah.rb'"
    end
  end

  desc "Copy the fixtures in to db/load_data"
  task :copy_fixtures do
    files = Dir[SURVEYOR_ROOT + '/script/survey_dsl/fixtures/*.yml']
    FileUtils.cp(files, SURVEYOR_ROOT + '/db/load_data/')
  end

  desc "Delete table content and load fixtures"
  task :load => :environment do
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      generated_fixture_location = File.join(SURVEYOR_ROOT, 'script','survey_dsl', 'fixtures', '*.{yml,csv}')
      fix_files = Dir.glob(generated_fixture_location) # Getting the list of fixtures from where they are orignially created we actually pull them from the db/load_data folder
      puts "Loading DSL fixture list from #{generated_fixture_location}"
      fix_files.each{ |f| puts " == " + File.basename(f, '.*')}
      raise "No fixtures in this location!" if fix_files.empty?
      raise "Error! Fixtures not copied to load folder #{SURVEYOR_ROOT + '/db/load_data/'}\r\nRun 'rake survey_dsl:copy_fixtures'" if Dir.glob(File.join(SURVEYOR_ROOT, 'db', 'load_data', '*.{yml,csv}')).empty?
      fix_files.each do |fixture_file|
        puts "added fixtures to table '#{File.basename(fixture_file, '.*')}'"
        Fixtures.create_fixtures(SURVEYOR_ROOT + '/db/load_data', File.basename(fixture_file, '.*'))
      end
  end
end

namespace :surveyor do
  
  desc "copies over assets from the plugin directory to the app root 'public/[:stylesheets,:images,:javascripts]/surveyor' along with migrations"
  task :init => ['surveyor:copy_migrations', 'surveyor:build_css','surveyor:copy_css', 'surveyor:copy_js', 'surveyor:copy_img']

  desc "generates css from sass files"
  task :build_css do
    root = "#{RAILS_ROOT}/vendor/plugins/surveyor/assets/stylesheets"
    puts "bulding css from sass"
    `sass #{root}/sass/surveyor.sass #{root}/surveyor.css`
  end
  
  desc "copies css from plugin assets folder to app public/stylesheets/surveyor folder"
  task :copy_css do
    puts "copying css to application"
    FileUtils.mkdir_p "#{RAILS_ROOT}/public/stylesheets/surveyor"
    FileUtils.cp Dir["#{SURVEYOR_ROOT}/assets/stylesheets/*.css"],"#{RAILS_ROOT}/public/stylesheets/surveyor/"
  end

  desc "copies js from plugin assets folder to app public/javascripts/surveyor folder"
  task :copy_js do
    puts "copying javascripts to application"
    FileUtils.mkdir_p "#{RAILS_ROOT}/public/javascripts/surveyor"
    FileUtils.cp Dir["#{SURVEYOR_ROOT}/assets/javascripts/*.js"],"#{RAILS_ROOT}/public/javascripts/surveyor/"
  end

  desc "copies images from plugin assets folder to app public/imges/surveyor folder"
  task :copy_img do
    puts "copying images to application"
    FileUtils.mkdir_p "#{RAILS_ROOT}/public/images/surveyor"
    FileUtils.cp Dir["#{SURVEYOR_ROOT}/assets/images/*"],"#{RAILS_ROOT}/public/images/surveyor/"
  end
 
  desc "copies migrations to the apps db/migrations folder"
  task :copy_migrations do
    puts "copying migrations to application"
    FileUtils.mkdir_p "#{RAILS_ROOT}/db/migrate"
    FileUtils.cp Dir["#{SURVEYOR_ROOT}/db/migrate/*.rb"], "#{RAILS_ROOT}/db/migrate"
  end

end
