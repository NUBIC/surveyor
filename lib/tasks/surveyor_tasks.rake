require File.join(File.dirname(__FILE__), "../../script/surveyor/survey_parser")
require 'active_record/fixtures'

namespace :surveyor do

  desc "generate and load survey fixtures from survey file (shortcut for rake surveyor:generate and rake surveyor:load)"
  task :import => [:generate_fixtures, :load_fixtures]
  
  desc "generate survey fixtures from survey file"
  task :generate_fixtures => :environment do
    raise "usage: file name required e.g. 'FILE=surveys/kitchen_sink_survey.rb'" if ENV["FILE"].blank?
    SurveyParser.parse(File.join(RAILS_ROOT, ENV["FILE"]))
  end

  desc "load survey fixtures"
  task :load_fixtures => :environment do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)

    fixture_dir = File.join(RAILS_ROOT, "surveys", "fixtures")
    fixtures = Dir.glob("#{fixture_dir}/*.yml")
    raise "No fixtures found." if fixtures.empty?
    
    fixtures.each do |file_name|
      puts "Loading #{file_name}..."
      Fixtures.create_fixtures(fixture_dir, File.basename(file_name, '.*'))
    end
  end

end
