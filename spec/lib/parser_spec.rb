require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::Parser do
  before(:each) do
    @parser = Surveyor::Parser.new
  end
  it "should translate shortcuts into full model names" do
    @parser.send(:full, "section").should == "survey_section"
    @parser.send(:full, "g").should == "question_group"
    @parser.send(:full, "repeater").should == "question_group"
    @parser.send(:full, "label").should == "question"
    @parser.send(:full, "vc").should == "validation_condition"
    @parser.send(:full, "vcondition").should == "validation_condition"
  end
  it "should translate 'condition' based on context" do
    @parser.send(:full, "condition").should == "dependency_condition"
    @parser.send(:full, "c").should == "dependency_condition"
    @parser.context[:validation] = Validation.new
    @parser.send(:full, "condition").should == "validation_condition"
    @parser.send(:full, "c").should == "validation_condition"
    @parser.context[:validation] = nil
    @parser.send(:full, "condition").should == "dependency_condition"
    @parser.send(:full, "c").should == "dependency_condition"
  end
  it "should identify models that take blocks" do
    @parser.send(:block_models).should == %w(survey survey_section question_group)
  end
  
  
end