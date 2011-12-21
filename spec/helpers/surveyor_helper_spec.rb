require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveyorHelper do
  before(:each) do
    
  end
  it "should return the question text with number" do
    q1 = Factory(:question)
    q2 = Factory(:question, :display_type => "label")
    q3 = Factory(:question, :dependency => Factory(:dependency))
    q4 = Factory(:question, :display_type => "image", :text => "something.jpg")
    q5 = Factory(:question, :question_group => Factory(:question_group))
    helper.q_text(q1).should == "1) #{q1.text}"
    helper.q_text(q2).should == q2.text
    helper.q_text(q3).should == q3.text
    
    dir = "images"
    if Rails.application.config.respond_to?(:assets) && Rails.application.config.assets
      dir = "assets"
    end
    
    helper.q_text(q4).should == %Q(<img alt="Something" src="/#{dir}/something.jpg" />)
    helper.q_text(q5).should == q5.text
  end
  require 'mustache'
  class FakeMustacheContext < ::Mustache
    def site
      "Northwestern"
    end
    def somethingElse
      "something new"
    end
    
    def group
      "NUBIC"
    end
  end
  it "should return text with with substituted value" do
    q1 = Factory(:question, :text => "You are in {{site}}")
    label = Factory(:question, :display_type => "label", :text => "Testing {{somethingElse}}")
    helper.q_text(q1, FakeMustacheContext).should == "1) You are in Northwestern"
    helper.q_text(label, FakeMustacheContext).should == "Testing something new"
  end
  it "should return help_text for question with substituted value" do
    q2 = Factory(:question, :display_type => "label", :text => "Is you site Northwestern?", :help_text => "If your site is not {{site}}, pick 'no' for the answer") 
    helper.render_help_text(q2, FakeMustacheContext).should == "If your site is not Northwestern, pick 'no' for the answer"
  end
  it "should return help_text for group text with number" do
    g1 = Factory(:question_group, :text => "You are part of the {{group}}")
    helper.q_text(g1, FakeMustacheContext).should == "1) You are part of the NUBIC"
  end
  it "should return help_text for group text" do
    g1 = Factory(:question_group, :text => "You are part of the {{group}}", :help_text => "Make sure you know what the {{group}} stands for")
    helper.render_help_text(g1, FakeMustacheContext).should == "Make sure you know what the NUBIC stands for"
  end

  it "should return rendered text for answer" do
    q1 = Factory(:question, :text => "Do you work for {{site}}", :answers => [a1 = Factory(:answer, :text => "No, I don't work for {{site}}"), a2 = Factory(:answer, :text => "Yes, I do work for {{site}}") ])
    helper.a_text(a1, nil, FakeMustacheContext).should == "No, I don't work for Northwestern"
    helper.a_text(a2, nil, FakeMustacheContext).should == "Yes, I do work for Northwestern"    
  end
  
  it "should return the group text with number" do
    g1 = Factory(:question_group)
    helper.q_text(g1, FakeMustacheContext).should == "1) #{g1.text}"
  end

  it "should find or create responses, with index" do
    q1 = Factory(:question, :answers => [a = Factory(:answer, :text => "different")])
    q2 = Factory(:question, :answers => [b = Factory(:answer, :text => "strokes")])
    q3 = Factory(:question, :answers => [c = Factory(:answer, :text => "folks")])
    rs = Factory(:response_set, :responses => [r1 = Factory(:response, :question => q1, :answer => a), r3 = Factory(:response, :question => q3, :answer => c, :response_group => 1)])

    helper.response_for(rs, nil).should == nil
    helper.response_for(nil, q1).should == nil
    helper.response_for(rs, q1).should == r1
    helper.response_for(rs, q1, a).should == r1
    helper.response_for(rs, q2).attributes.should == Response.new(:question => q2, :response_set => rs).attributes
    helper.response_for(rs, q2, b).attributes.should == Response.new(:question => q2, :response_set => rs).attributes
    helper.response_for(rs, q3, c, "1").should == r3
    
  end
  it "should keep an index of responses" do
    helper.response_idx.should == "1"
    helper.response_idx.should == "2"
    helper.response_idx(false).should == "2"
    helper.response_idx.should == "3"
  end
  it "should translate response class into attribute" do
    helper.rc_to_attr(:string).should == :string_value
    helper.rc_to_attr(:text).should == :text_value
    helper.rc_to_attr(:integer).should == :integer_value
    helper.rc_to_attr(:float).should == :float_value
    helper.rc_to_attr(:datetime).should == :datetime_value
    helper.rc_to_attr(:date).should == :datetime_value
    helper.rc_to_attr(:time).should == :datetime_value
  end
end