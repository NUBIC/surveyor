require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::Unparser do
  before(:each) do
    @survey = Survey.new(:title => "Simple survey", :description => "very simple")
    section = @survey.sections.build(:title => "Simple section")
    q1 = section.questions.build(:text => "What is your favorite color?", :reference_identifier => 1, :pick => :none)
  end
  it "should unparse a basic survey, section, and question" do
    Surveyor::Unparser.unparse(@survey).should ==
<<-dsl
survey "Simple survey", :description=>"very simple" do
  section "Simple section" do
    question_1 "What is your favorite color?"
  end
end
dsl
  end
end