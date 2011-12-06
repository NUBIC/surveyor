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
  it "should return a survey object" do
    Surveyor::Parser.new.parse("survey 'hi' do\n end").is_a?(Survey).should be_true
  end
  
  it "should parse prepopulated token" do
    result = Question.parse_prepopulated_token("Hello, we are calling from :prepopulate=>[global_config.ncs_center]")
    result.fileName.should == "global_config"
    result.variable.should == "ncs_center"    
  end
  
  it "should fail parsing prepopulated token" do
    result = Question.parse_prepopulated_token("Hello, we are calling from :prepop=>(global_config.ncs_center]")
    result.should be_nil
  end  
  
  it "should get absolute path for file name " do
    Question.global_config_path("testFileName").should == "#{Rails.root}/config/data/testFileName.yml"
  end
  
  it "should load global file by absolute file path" do
    result = Question.load_global_file("#{Rails.root}/config/data/global_config.yml")
    result.should_not be_nil
  end
  
  it "should fail loading global file by absolute file path" do
    result = Question.load_global_file("#{Rails.root}/config/data/global_config_another.yml")
    result.should be_nil
  end
  
  it "should substitute prepopulated test" do
    result = Question.substitute_text("Our phone number is :prepopulate=>[global_config.TOLL_FREE_NUMBER]", "1-800-555-5555")
    expectedResult = "Our phone number is 1-800-555-5555"
    result.should == expectedResult
  end
  
  it "should fail substituting the prepopulated field" do
    result = Question.substitute_text("Our phone number is :prepopulate=>(global_config.TOLL_FREE_NUMBER)", "1-800-555-5555")
    expectedResult = "Our phone number is :prepopulate=>(global_config.TOLL_FREE_NUMBER)"
    result.should == expectedResult
  end  
end