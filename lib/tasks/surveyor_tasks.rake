desc "generate and load survey (specify FILE=surveys/your_survey.rb)"
task :surveyor => :"surveyor:parse"

namespace :surveyor do
  task :parse => :environment do
    raise "USAGE: file name required e.g. 'FILE=surveys/kitchen_sink_survey.rb'" if ENV["FILE"].blank?
    file = File.join(RAILS_ROOT, ENV["FILE"])
    raise "File does not exist: #{file}" unless FileTest.exists?(file)
    puts "--- Parsing #{file} ---"
    Surveyor::Parser.parse File.read(file)
    puts "--- Done #{file} ---"
  end
  desc "generate and load survey from REDCap Data Dictionary (specify FILE=surveys/redcap.csv)"
  task :redcap => :environment do
    raise "USAGE: file name required e.g. 'FILE=surveys/redcap_demo_survey.csv'" if ENV["FILE"].blank?
    file = File.join(RAILS_ROOT, ENV["FILE"])
    raise "File does not exist: #{file}" unless FileTest.exists?(file)
    puts "--- Parsing #{file} ---"
    Surveyor::RedcapParser.parse File.read(file), File.basename(file, ".csv")
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
end

namespace :spec do
  namespace :plugins do
    begin
      require 'spec/rake/spectask'
      desc "Runs the examples for surveyor"    
      Spec::Rake::SpecTask.new(:surveyor) do |t|
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
        t.spec_files = FileList['vendor/plugins/surveyor/spec/**/*_spec.rb']
      end
    rescue MissingSourceFile
    end
  end  
end
