desc "generate and load survey (specify FILE=surveys/your_survey.rb)"
task :surveyor => :"surveyor:parse"

namespace :surveyor do
  task :parse => :environment do
    raise "USAGE: file name required e.g. 'FILE=surveys/kitchen_sink_survey.rb'" if ENV["FILE"].blank?
    file = File.join(Rails.root, ENV["FILE"])
    raise "File does not exist: #{file}" unless FileTest.exists?(file)
    puts "--- Parsing #{file} ---"
    Surveyor::Parser.parse_file(file, {:trace => Rake.application.options.trace})
    puts "--- Done #{file} ---"
  end
  desc "generate and load survey from REDCap Data Dictionary (specify FILE=surveys/redcap.csv)"
  task :redcap => :environment do
    raise "USAGE: file name required e.g. 'FILE=surveys/redcap_demo_survey.csv'" if ENV["FILE"].blank?
    file = File.join(Rails.root, ENV["FILE"])
    raise "File does not exist: #{file}" unless FileTest.exists?(file)
    puts "--- Parsing #{file} ---"
    Surveyor::RedcapParser.parse File.read(file), File.basename(file, ".csv"), {:trace => Rake.application.options.trace}
    puts "--- Done #{file} ---"
  end
  desc "generate a surveyor DSL file from a survey"
  task :unparse => :environment do
    surveys = Survey.all
    if surveys
      puts "The following surveys are available"
      surveys.each do |survey|
        puts "#{survey.id} #{survey.title}"
      end
      print "Which survey would you like to unparse? "
      id = $stdin.gets.to_i
      if survey_to_unparse = surveys.detect{|s| s.id == id}
        filename = "surveys/#{survey_to_unparse.access_code}_#{Date.today.to_s(:db)}.rb"
        puts "unparsing #{survey_to_unparse.title} to #{filename}"
        File.open(filename, 'w') {|f| f.write(Surveyor::Unparser.unparse(survey_to_unparse))}
      else
        puts "not found"
      end
    else
      puts "There are no surveys available"
    end
  end
  desc "remove surveys (that don't have response sets)"
  task :remove => :environment do
    surveys = Survey.all.delete_if{|s| !s.response_sets.blank?}
    if surveys
      puts "The following surveys do not have any response sets"
      surveys.each do |survey|
        puts "#{survey.id} #{survey.title}"
      end
      print "Which survey would you like to remove? "
      id = $stdin.gets.to_i
      if survey_to_delete = surveys.detect{|s| s.id == id}
        puts "removing #{survey_to_delete.title}"
        survey_to_delete.destroy
      else
        put "not found"
      end
    else
      puts "There are no surveys without response sets"
    end
  end
  desc "dump all responses to a given survey"
  task :dump => :environment do
    require 'fileutils.rb'
    survey_version = ENV["SURVEY_VERSION"]
    access_code = ENV["SURVEY_ACCESS_CODE"]

    raise "USAGE: rake surveyor:dump SURVEY_ACCESS_CODE=<access_code> [OUTPUT_DIR=<dir>] [SURVEY_VERSION=<survey_version>]" unless access_code
    params_string = "code #{access_code}"

    surveys = Survey.where(:access_code => access_code).order("survey_version ASC")
    if survey_version.blank?
      survey = surveys.last
    else
      params_string += " and survey_version #{survey_version}"
      survey = surveys.where(:survey_version => survey_version).first
    end

    raise "No Survey found with #{params_string}" unless survey
    dir = ENV["OUTPUT_DIR"] || Rails.root
    mkpath(dir) # Create all non-existent directories
    full_path = File.join(dir,"#{survey.access_code}_v#{survey.survey_version}_#{Time.now.to_i}.csv")
    File.open(full_path, 'w') do |f|
      survey.response_sets.each_with_index{|r,i| f.write(r.to_csv(true, i == 0)) } # print access code every time, print_header first time
    end
  end
end
