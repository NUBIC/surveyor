require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionGroup do
  before(:each) do
    @question_group = QuestionGroup.new
  end

  it "should be valid" do
    @question_group.should be_valid
  end
end
