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
    helper.q_text(q4).should == '<img alt="Something" src="/images/something.jpg" />'
    helper.q_text(q5).should == q5.text
  end
  it "should return the group text with number" do
    g1 = Factory(:question_group)
    helper.q_text(g1).should == "1) #{g1.text}"
  end
  it "should find or create responses, with index" do
    q1 = Factory(:question, :answers => [a = Factory(:answer, :text => "different")])
    q2 = Factory(:question, :text => "Foo", :answers => [Factory(:answer)])
    rs = Factory(:response_set, :responses => [r = Factory(:response, :question => q1, :answer => a)])
    
    helper.response_for(rs, nil).should == nil
    helper.response_for(nil, q1).should == nil
    helper.response_for(rs, q1).should == r
    helper.response_for(rs, q1, a).should == r
    helper.response_for(rs, q2).attributes.should == Response.new(:question => q2, :response_set => rs).attributes
  end
  it "should keep an index of responses" do
    helper.response_idx.should == "1"
    helper.response_idx.should == "2"
    helper.response_idx(false).should == "2"
    helper.response_idx.should == "3"
  end
end