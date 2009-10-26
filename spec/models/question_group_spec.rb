require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionGroup do
  before(:each) do
    @question_group = Factory(:question_group)
  end

  it "should be valid" do
    @question_group.should be_valid
  end
  it "should have defaults" do
    @question_group = QuestionGroup.new
    @question_group.display_type.should == "inline"
    @question_group.renderer.should == :inline
    @question_group.display_type = nil
    @question_group.renderer.should == :default
  end
  it "should return its custom css class" do
    @question_group.custom_class = "foo bar"
    @question_group.css_class(Factory(:response_set)).should == "foo bar"
  end
  it "should return its dependency class" do
    @dependency = Factory(:dependency)
    @question_group.dependency = @dependency
    @dependency.should_receive(:is_met?).and_return(true)
    @question_group.css_class(Factory(:response_set)).should == "dependent"

    @dependency.should_receive(:is_met?).and_return(false)
    @question_group.css_class(Factory(:response_set)).should == "dependent hidden"

    @question_group.custom_class = "foo bar"
    @dependency.should_receive(:is_met?).and_return(false)
    @question_group.css_class(Factory(:response_set)).should == "dependent hidden foo bar"
  end
end
