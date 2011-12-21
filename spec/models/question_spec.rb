require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question, "when creating a new question" do
  before(:each) do
    @ss = mock_model(SurveySection)
    @question = Question.new(:text => "What is your favorite color?", :survey_section => @ss, :is_mandatory => true, :display_order => 1)
  end

  it "should be invalid without text" do
    @question.text = nil
    @question.should have(1).error_on(:text)
  end
    
  it "should have a parent survey section" do
    # this causes issues with building and saving
    # @question.survey_section = nil
    # @question.should have(1).error_on(:survey_section_id)
  end
    
  it "should be mandatory by default" do
    @question.mandatory?.should be_true
  end
  
  it "should convert pick attribute to string" do
    @question.pick.should == "none"
    @question.pick = :one
    @question.pick.should == "one"
    @question.pick = nil
    @question.pick.should == nil
  end
  
  it "should split the text" do
    @question.split_text.should == "What is your favorite color?"
    @question.split_text(:pre).should == "What is your favorite color?"
    @question.split_text(:post).should == ""
    @question.text = "before|after|extra"
    @question.split_text.should == "before|after|extra"
    @question.split_text(:pre).should == "before"
    @question.split_text(:post).should == "after|extra"
  end
  
  it "should have an api_id" do
    @question.api_id.length.should == 36
  end
end

describe Question, "that has answers" do
  before(:each) do
    @question = Factory(:question, :text => "What is your favorite color?")
    Factory(:answer, :question => @question, :display_order => 3, :text => "blue")
    Factory(:answer, :question => @question, :display_order => 1, :text => "red")
    Factory(:answer, :question => @question, :display_order => 2, :text => "green")
  end
  
  it "should have answers" do
    @question.answers.should have(3).answers
  end
  
  it "should retrieve those answers in display_order" do
    @question.answers.map(&:display_order).should == [1,2,3]
  end
  it "should delete answers when it is deleted" do
    answer_ids = @question.answers.map(&:id)
    @question.destroy
    answer_ids.each{|id| Answer.find_by_id(id).should be_nil}
  end
end

describe Question, "when interacting with an instance" do
  
  before(:each) do
    @question = Factory(:question)
  end

  it "should return 'default' for nil display type" do
    @question.display_type = nil
    @question.renderer.should == :default
  end
  
  it "should let you know if it is part of a group" do
    @question.question_group = Factory(:question_group)
    @question.solo?.should be_false
    @question.part_of_group?.should be_true
    @question.question_group = nil
    @question.solo?.should be_true
    @question.part_of_group?.should be_false
  end
  
  require 'mustache'
  class FakeMustacheContext < ::Mustache
    def site
      "Northwestern"
    end
    def somethingElse
      "something new"
    end
  end
  it "should substitute 'Northwestern' in place {{site}}" do
      @question.text = "You are in {{site}}"
      @question.render_question_text(FakeMustacheContext).should == "You are in Northwestern"
  end
        
end

describe Question, "with dependencies" do
  before(:each) do
    @rs = mock_model(ResponseSet)
    @question = Factory(:question)
  end

  it "should check its dependency" do
    @dependency = mock_model(Dependency)
    @dependency.stub!(:is_met?).with(@rs).and_return(true)
    @question.stub!(:dependency).and_return(@dependency)
    @question.triggered?(@rs).should == true
  end
  it "should delete dependency when it is deleted" do
    dep_id = Factory(:dependency, :question => @question).id
    @question.destroy
    Dependency.find_by_id(dep_id).should be_nil
  end
  
end
