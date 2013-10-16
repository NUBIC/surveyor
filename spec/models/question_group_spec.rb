# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionGroup do
  let(:question_group){ FactoryGirl.create(:question_group) }
  let(:dependency){ FactoryGirl.create(:dependency) }
  let(:response_set){ FactoryGirl.create(:response_set) }

  context "when creating" do
    it { question_group.should be_valid }
    it "#display_type = inline by default" do
      question_group.display_type = "inline"
      question_group.renderer.should == :inline
    end
    it "#renderer == 'default' when #display_type = nil" do
      question_group.display_type = nil
      question_group.renderer.should == :default
    end
    it "interprets symbolizes #display_type to #renderer" do
      question_group.display_type = "foo"
      question_group.renderer.should == :foo
    end
    it "reports DOM ready #css_class based on dependencies" do
      question_group.dependency = dependency
      dependency.should_receive(:is_met?).and_return(true)
      question_group.css_class(response_set).should == "g_dependent"

      dependency.should_receive(:is_met?).and_return(false)
      question_group.css_class(response_set).should == "g_dependent g_hidden"

      question_group.custom_class = "foo bar"
      dependency.should_receive(:is_met?).and_return(false)
      question_group.css_class(response_set).should == "g_dependent g_hidden foo bar"
    end
  end

  context "with translations" do
    require 'yaml'
    let(:survey){ FactoryGirl.create(:survey) }
    let(:survey_section){ FactoryGirl.create(:survey_section) }
    let(:survey_translation){
      FactoryGirl.create(:survey_translation, :locale => :es, :translation => {
        :question_groups => {
          :goodbye => {
            :text => "¡Adios!"
          }
        }
      }.to_yaml)
    }
    let(:question){ FactoryGirl.create(:question) }
    before do
      question_group.text = "Goodbye"
      question_group.reference_identifier = "goodbye"
      question_group.questions = [question]
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it "returns its own translation" do
      question_group.translation(:es)[:text].should == "¡Adios!"
    end
    it "returns its own default values" do
      question_group.translation(:de).should == {"text" => "Goodbye", "help_text" => nil}
    end
  end
end
