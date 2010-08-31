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
