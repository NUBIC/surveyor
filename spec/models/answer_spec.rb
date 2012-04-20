require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer, "when creating a new answer" do
  before(:each) do
    @answer = Factory(:answer, :text => "Red")
  end
  
  it "should be valid" do
    @answer.should be_valid
  end
  
  # this causes issues with building and saving answers to questions within a grid.
  # it "should be invalid without a question_id" do
  #   @answer.question_id = nil
  #   @answer.should_not be_valid
  # end
  
  it "should tell me its css class" do
    @answer.custom_class = "foo bar"
    @answer.css_class.should == "foo bar"
    @answer.is_exclusive = true
    @answer.css_class.should == "exclusive foo bar"
  end
  
  it "should hide the label when display_type hidden_label is set" do
    @answer.split_or_hidden_text.should == "Red"
    @answer.display_type = "hidden_label"
    @answer.split_or_hidden_text.should == ""
  end
  it "should split up pre/post labels" do
    @answer.text = "before|after|extra"
    @answer.split_or_hidden_text(:pre).should == "before"
    @answer.split_or_hidden_text(:post).should == "after|extra"
  end
  it "should delete validation when it is deleted" do
    v_id = Factory(:validation, :answer => @answer).id
    @answer.destroy
    Validation.find_by_id(v_id).should be_nil
  end
  
  it "should have an api_id" do
    @answer.api_id.length.should == 36
  end
  
  it "should protect api_id, timestamps" do
    saved_attrs = @answer.attributes
    lambda {@answer.update_attributes(:created_at => 3.days.ago, :modified_at => 3.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    lambda {@answer.update_attributes(:api_id => "NEW")}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    @answer.attributes.should == saved_attrs
  end
  
  require 'mustache'
  class FakeMustacheContext < ::Mustache
    def site
      "Northwestern"
    end
  end
  it "should substitute 'Northwestern' in place {{site}}" do
      @answer.text = "You are in {{site}}"
      @answer.split_or_hidden_text(nil, FakeMustacheContext).should == "You are in Northwestern"
  end
end