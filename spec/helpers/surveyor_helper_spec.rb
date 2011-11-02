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
  it "should return the group text with number" do
    g1 = Factory(:question_group)
    helper.q_text(g1).should == "1) #{g1.text}"
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

  it "renders an answer" do
fragment =  <<HERE
%p
  = q.to_s
%p
  = a.to_s
%p
  = f.to_s
%p
  = rg.to_s
%p
  = g.to_s
HERE

    q, a, f, rg, g = 1, 2, 3, 4, 5
    template = Haml::Engine.new(fragment)
    Haml::Engine.should_receive(:new).and_return(template)
    helper.render_answer(q, a, f, rg, g).should == "<p>\n  1\n</p>\n<p>\n  2\n</p>\n<p>\n  3\n</p>\n<p>\n  4\n</p>\n<p>\n  5\n</p>\n"
  end


  it "renders a question" do
fragment =  <<HERE
%p
  = g.to_s
%p
  = rg.to_s
%p
  = q.to_s
%p
  = f.to_s
HERE

    g, rg, q, f = 1, 2, 3, 4
    template = Haml::Engine.new(fragment)
    Haml::Engine.should_receive(:new).and_return(template)
    helper.render_question(g, rg, q, f).should == "<p>\n  1\n</p>\n<p>\n  2\n</p>\n<p>\n  3\n</p>\n<p>\n  4\n</p>\n"
  end
end