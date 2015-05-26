# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Survey do
  let(:survey){ FactoryGirl.create(:survey) }

  context "when creating" do
    it "is invalid without #title" do
      survey.title = nil
      survey.should have(1).error_on :title
    end
    it "adjust #survey_version" do
      original = Survey.new(:title => "Foo")
      original.save.should be_true
      original.survey_version.should == 0
      imposter = Survey.new(:title => "Foo")
      imposter.save.should be_true
      imposter.title.should == "Foo"
      imposter.survey_version.should == 1
      bandwagoneer = Survey.new(:title => "Foo")
      bandwagoneer.save.should be_true
      bandwagoneer.title.should == "Foo"
      bandwagoneer.survey_version.should == 2
    end
    it "prevents duplicate #survey_version" do
      original = Survey.new(:title => "Foo")
      original.save.should be_true
      imposter = Survey.new(:title => "Foo")
      imposter.save.should be_true
      imposter.survey_version = 0
      imposter.save.should be_false
      imposter.should have(1).error_on(:survey_version)
    end
    it "doesn't adjust #title when" do
      original = FactoryGirl.create(:survey, :title => "Foo")
      original.save.should be_true
      original.update_attributes(:title => "Foo")
      original.title.should == "Foo"
    end
    it "has #api_id with 36 characters by default" do
      survey.api_id.length.should == 36
    end
  end

  context "activating" do
    it { survey.active?.should }
    it "both #inactive_at and #active_at == nil by default" do
      survey.active_at.should be_nil
      survey.inactive_at.should be_nil
    end
    it "#active_at on a certain date/time" do
      survey.inactive_at = 2.days.from_now
      survey.active_at = 2.days.ago
      survey.active?.should be_true
    end
    it "#inactive_at on a certain date/time" do
      survey.active_at = 3.days.ago
      survey.inactive_at = 1.days.ago
      survey.active?.should be_false
    end
    it "#activate! and #deactivate!" do
      survey.activate!
      survey.active?.should be_true
      survey.deactivate!
      survey.active?.should be_false
    end
    it "nils out past values of #inactive_at on #activate!" do
      survey.inactive_at = 5.days.ago
      survey.active?.should be_false
      survey.activate!
      survey.active?.should be_true
      survey.inactive_at.should be_nil
    end
    it "nils out pas values of #active_at on #deactivate!" do
      survey.active_at = 5.days.ago
      survey.active?.should be_true
      survey.deactivate!
      survey.active?.should be_false
      survey.active_at.should be_nil
    end
  end

  context "with survey_sections" do
    let(:s1){ FactoryGirl.create(:survey_section, :survey => survey, :title => "wise", :display_order => 2)}
    let(:s2){ FactoryGirl.create(:survey_section, :survey => survey, :title => "er", :display_order => 3)}
    let(:s3){ FactoryGirl.create(:survey_section, :survey => survey, :title => "bud", :display_order => 1)}
    let(:q1){ FactoryGirl.create(:question, :survey_section => s1, :text => "what is wise?", :display_order => 2)}
    let(:q2){ FactoryGirl.create(:question, :survey_section => s2, :text => "what is er?", :display_order => 4)}
    let(:q3){ FactoryGirl.create(:question, :survey_section => s2, :text => "what is mill?", :display_order => 3)}
    let(:q4){ FactoryGirl.create(:question, :survey_section => s3, :text => "what is bud?", :display_order => 1)}
    before do
      [s1, s2, s3].each{|s| survey.sections << s }
      s1.questions << q1
      s2.questions << q2
      s2.questions << q3
      s3.questions << q4
    end

    it{ survey.should have(3).sections}
    it "gets survey_sections in order" do
      survey.sections.order("display_order asc").should == [s3, s1, s2]
      survey.sections.order("display_order asc").map(&:display_order).should == [1,2,3]
    end
    it "gets survey_sections_with_questions in order" do
      survey.sections.order("display_order asc").map{|ss| ss.questions.order("display_order asc")}.flatten.should have(4).questions
      survey.sections.order("display_order asc").map{|ss| ss.questions.order("display_order asc")}.flatten.should == [q4,q1,q3,q2]
    end
    it "deletes child survey_sections when deleted" do
      survey_section_ids = survey.sections.map(&:id)
      survey.destroy
      survey_section_ids.each{|id| SurveySection.find_by_id(id).should be_nil}
    end
  end

  context "serialization" do
    let(:s1){ FactoryGirl.create(:survey_section, :survey => survey, :title => "wise") }
    let(:s2){ FactoryGirl.create(:survey_section, :survey => survey, :title => "er") }
    let(:q1){ FactoryGirl.create(:question, :survey_section => s1, :text => "what is wise?") }
    let(:q2){ FactoryGirl.create(:question, :survey_section => s2, :text => "what is er?") }
    let(:q3){ FactoryGirl.create(:question, :survey_section => s2, :text => "what is mill?") }
    before do
      [s1, s2].each{|s| survey.sections << s }
      s1.questions << q1
      s2.questions << q2
      s2.questions << q3
    end

    it "includes title, sections, and questions" do
      actual = survey.as_json
      actual[:title].should == 'Simple survey'
      actual[:sections].size.should == 2
      actual[:sections][0][:questions_and_groups].size.should == 1
      actual[:sections][1][:questions_and_groups].size.should == 2
    end
  end

  context "with translations" do
    require 'yaml'
    let(:survey_translation){
      FactoryGirl.create(:survey_translation, :locale => :es, :translation => {
        :title => "Un idioma nunca es suficiente"
      }.to_yaml)
    }
    before do
      survey.translations << survey_translation
    end
    it "returns its own translation" do
      YAML.load(survey_translation.translation).should_not be_nil
      survey.translation(:es)[:title].should == "Un idioma nunca es suficiente"
    end
    it "returns its own default values" do
      survey.translation(:de).should == {"title" => survey.title, "description" => survey.description}
    end
  end
end
