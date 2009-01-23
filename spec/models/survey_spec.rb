require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# Validations
describe Survey, "when saving a new one" do
  before(:each) do
    @survey = Survey.new
    @survey.title = "Foo"
  end
  
  it "should be invalid without a title" do
    @survey.title = nil
    @survey.should have(1).error_on(:title)
  end
end

# Associations
describe Survey, "that has sections" do
  before(:each) do
    @survey = Survey.create(:title => "foo")
    @s1 = @survey.sections.create(:title => "wise", :display_order => 2)
    @s2 = @survey.sections.create(:title => "er", :display_order => 3)
    @s3 = @survey.sections.create(:title => "bud", :display_order => 1)
    @q1 = @s1.questions.create(:text => "what is wise?")
    @q2 = @s2.questions.create(:text => "what is er?", :display_order => 2)
    @q3 = @s2.questions.create(:text => "what is mill?", :display_order => 1)
    @q4 = @s3.questions.create(:text => "what is bud?")
  end

  it "should return survey_sections in display order" do
    @survey.sections.should have(3).sections
    @survey.sections.should == [@s3, @s1, @s2]
  end
  
  it "should return survey_sections_with_questions in display order" do
    @survey.sections_with_questions.map(&:questions).flatten.should have(4).questions
    @survey.sections_with_questions.map(&:questions).flatten.should == [@q4,@q1,@q3,@q2]
  end

end

# Methods
describe Survey do
  before(:each) do
    @survey = Survey.new
  end

  it "should be inactive by default" do
    @survey.active?.should == false
  end

  it "should be active or active as of a certain date/time" do
    @survey.inactive_at = 3.days.ago
    @survey.active_at = 2.days.ago
    @survey.active?.should be_true
    @survey.inactive_at.should be_nil
  end
  
  it "should be able to deactivate as of a certain date/time" do
    @survey.active_at = 2.days.ago
    @survey.inactive_at = 3.days.ago
    @survey.active?.should be_false
    @survey.active_at.should be_nil
  end
  
  it "should activate and deactivate" do
    @survey.activate!
    @survey.active?.should be_true
    @survey.deactivate!
    @survey.active?.should be_false
  end
  
end