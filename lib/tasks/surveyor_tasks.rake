require File.join(File.dirname(__FILE__), "../../script/surveyor/dslparse")
require 'active_record/fixtures'

namespace :surveyor do

  desc "generate and load survey fixtures from survey file"
  task :bootstrap => [:generate, :load]
  
  desc "generate survey fixtures from survey file"
  task :generate => :environment do
    raise "usage: file name required e.g. 'FILE=surveys/kitchen_sink_survey.rb'" if ENV["FILE"].blank?
    DSLParse.parse(File.join(RAILS_ROOT, ENV["FILE"]))
  end

  desc "load survey fixtures"
  task :load => :environment do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)

    fixture_dir = File.join(RAILS_ROOT, "surveys", "fixtures")
    fixtures = Dir.glob("#{fixture_dir}/*.yml"))
    raise "No fixtures found." if fixtures.empty?
    
    fixtures.each do |file_name|
      puts "Loading #{file_name}..."
      Fixtures.create_fixtures(File.join(fixture_dir, file_name))
    end
  end

end
