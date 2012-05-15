require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# Validations
describe Survey, "when saving a new one" do
  before(:each) do
    @survey = Factory(:survey, :title => "Foo")
  end

  it "should be invalid without a title" do
    @survey.title = nil
    @survey.should have(1).error_on(:title)
  end

  it "should adjust the survey_version to save unique survey_version for each title" do
    original = Survey.new(:title => "Foo")
    original.save.should be_true
    original.survey_version.should == 0
    imposter = Survey.new(:title => "Foo")
    imposter.save.should be_true
    imposter.title.should == "Foo"
    imposter.survey_version.should == 1
    bandwagoneer = Survey.new(:title => "Foo")
    bandwagoneer.save.should be_true
    bandwagoneer.title.should == "Foo"
    bandwagoneer.survey_version.should == 2
  end
  
  it "should not allow to have duplicate survey_versions of the survey" do
    survey = Survey.new(:title => "Foo")
    survey.save.should be_true
    imposter = Survey.new(:title => "Foo")
    imposter.save.should be_true
    imposter.survey_version = 0
    imposter.save.should be_false
    imposter.should have(1).error_on(:survey_version)
  end

  it "should not adjust the title when updating itself" do
    original = Factory(:survey, :title => "Foo")
    original.save.should be_true
    original.update_attributes(:title => "Foo")
    original.title.should == "Foo"
  end

  it "should have an api_id" do
    @survey.api_id.length.should == 36
  end
end

# Associations
describe Survey, "that has sections" do
  before(:each) do
    @survey = Factory(:survey, :title => "Foo")
    @s1 = Factory(:survey_section, :survey => @survey, :title => "wise", :display_order => 2)
    @s2 = Factory(:survey_section, :survey => @survey, :title => "er", :display_order => 3)
    @s3 = Factory(:survey_section, :survey => @survey, :title => "bud", :display_order => 1)
    @q1 = Factory(:question, :survey_section => @s1, :text => "what is wise?", :display_order => 2)
    @q2 = Factory(:question, :survey_section => @s2, :text => "what is er?", :display_order => 4)
    @q3 = Factory(:question, :survey_section => @s2, :text => "what is mill?", :display_order => 3)
    @q4 = Factory(:question, :survey_section => @s3, :text => "what is bud?", :display_order => 1)
  end

  it "should return survey_sections in display order" do
    @survey.sections.should have(3).sections
    @survey.sections.should == [@s3, @s1, @s2]
  end

  it "should return survey_sections_with_questions in display order" do
    @survey.sections_with_questions.map(&:questions).flatten.should have(4).questions
    @survey.sections_with_questions.map(&:questions).flatten.should == [@q4,@q1,@q3,@q2]
  end
  it "should delete survey sections when it is deleted" do
    section_ids = @survey.sections.map(&:id)
    @survey.destroy
    section_ids.each{|id| SurveySection.find_by_id(id).should be_nil}
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
  it "should have both inactive_at and active_at be null by default" do
    @survey.active_at.should be_nil
    @survey.inactive_at.should be_nil
  end
  
  it "should be active or active as of a certain date/time" do
    @survey.inactive_at = 2.days.from_now
    @survey.active_at = 2.days.ago
    @survey.active?.should be_true
  end

  it "should be able to deactivate as of a certain date/time" do
    @survey.active_at = 3.days.ago
    @survey.inactive_at = 1.days.ago
    @survey.active?.should be_false
  end

  it "should activate and deactivate" do
    @survey.activate!
    @survey.active?.should be_true
    @survey.deactivate!
    @survey.active?.should be_false
  end

  it "should should nil out values of inactive_at that are in the past on activate" do
    @survey.inactive_at = 5.days.ago
    @survey.active?.should be_false
    @survey.activate!
    @survey.active?.should be_true
    @survey.inactive_at.should be_nil
  end

  it "should should nil out values of active_at that are in the past on deactivate" do
    @survey.active_at = 5.days.ago
    @survey.active?.should be_true
    @survey.deactivate!
    @survey.active?.should be_false
    @survey.active_at.should be_nil
  end
  
  it "should protect access_code, api_id, active_at, inactive_at, timestamps" do
    saved_attrs = @survey.attributes
    if defined? ActiveModel::MassAssignmentSecurity::Error
      lambda {@survey.update_attributes(:access_code => "NEW")}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@survey.update_attributes(:api_id => "AND")}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@survey.update_attributes(:active_at => 2.days.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@survey.update_attributes(:inactive_at => 3.days.from_now)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      lambda {@survey.update_attributes(:created_at => 3.days.ago, :updated_at => 3.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    else
      @survey.update_attributes(:access_code => "NEW").should be_false
      @survey.update_attributes(:api_id => "AND").should be_false
      @survey.update_attributes(:active_at => 2.days.ago).should be_false
      @survey.update_attributes(:inactive_at => 3.days.from_now).should be_false
      @survey.attributes = {:created_at => 3.days.ago, :updated_at => 3.hours.ago} # automatically protected by Rails
    end
    @survey.attributes.should == saved_attrs
  end
end
