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
  desc "remove surveys (that don't have response sets)"
  task :remove => :environment do
    surveys = Survey.all.delete_if{|s| !s.response_sets.blank?}
    if surveys
      puts "The following surveys do not have any response sets"
      surveys.each do |survey|
        puts "#{survey.id} #{survey.title}"
      end
      puts "Which survey would you like to remove?"
      id = $stdin.gets.to_i
      if survey_to_delete = surveys.detect{|s| s.id == id}
        puts "removing #{survey_to_delete.title}"
        survey_to_delete.destroy
      else
        put "not found"
      end
    else
      puts "There are no surveys surveys without response sets"      
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
