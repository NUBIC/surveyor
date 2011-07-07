require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor do
  it "should write thousands of response sets" do
    Surveyor::Parser.parse(File.read(File.join(Rails.root, 'surveys', 'kitchen_sink_survey.rb')))
    survey = Survey.last
    rs = ResponseSet.create(:survey => survey)
    survey.sections.each{|s| s.questions.each{|q| rs.responses.create(:question => q, :answer => q.answers.first)}}
    Benchmark.bm 20 do |x|
      x.report "a test" do
        full_path = File.join(Rails.root,"#{survey.access_code}_#{Time.now.to_i}.csv")
        File.open(full_path, 'w') do |f|
          100.times do # adjust this to test
            survey.response_sets.each_with_index{|r,i| f.write(r.to_csv(true, i == 0)) } # print access code every time, print_header first time
          end
        end        
      end
    end
  end
end


