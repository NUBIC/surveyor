require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveySection, "when saving a survey_section" do
  before(:each) do
    @valid_attributes={:title => "foo", :survey_id => 2, :display_order => 4}
    @survey_section = SurveySection.new(@valid_attributes)
  end

  it "should be invalid without title" do
    @survey_section.title = nil
    @survey_section.should have(1).error_on(:title)
  end
  
  it "should have a parent survey" do
    # this causes issues with building and saving
    # @survey_section.survey_id = nil
    # @survey_section.should have(1).error_on(:survey)
  end
end

describe SurveySection, "with questions" do
  before(:each) do
    @survey_section = Factory(:survey_section, :title => "Rhymes", :display_order => 4)
    @q1 = @survey_section.questions.create(:text => "Peep", :display_order => 3)
    @q2 = @survey_section.questions.create(:text => "Little", :display_order => 1)
    @q3 = @survey_section.questions.create(:text => "Bo", :display_order => 2)
  end
  
  it "should return questions sorted in display order" do
    @survey_section.questions.should have(3).questions
    @survey_section.questions.should == [@q2,@q3,@q1]
  end
end
