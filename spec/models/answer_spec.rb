# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer do
  let(:answer){ FactoryBot.create(:answer) }

  context "when creating" do
    it { answer.should be_valid }
    it "deletes validation when deleted" do
      v_id = FactoryBot.create(:validation, :answer => answer).id
      answer.destroy
      Validation.find_by_id(v_id).should be_nil
    end

    it 'should check qualifying logic' do
      ['must', 'may', 'reject'].each do |ql|
        answer.qualify_logic = ql
        answer.save.should be true
      end

      answer.qualify_logic = nil
      answer.save.should be false
      answer.should have(1).error_on :qualify_logic

      answer.qualify_logic = ''
      answer.save.should be false
      answer.should have(1).error_on :qualify_logic

      answer.qualify_logic = 'accept'
      answer.save.should be false
      answer.should have(1).error_on :qualify_logic
    end
  end

  context "with mustache text substitution" do
    require 'mustache'
    let(:mustache_context){ Class.new(::Mustache){ def site; "Northwestern"; end; def foo; "bar"; end } }
    it "subsitutes Mustache context variables" do
      answer.text = "You are in {{site}}"
      answer.in_context(answer.text, mustache_context).should == "You are in Northwestern"
      answer.text_for(nil, mustache_context).should == "You are in Northwestern"

      answer.help_text = "{{site}} is your site"
      answer.in_context(answer.help_text, mustache_context).should == "Northwestern is your site"
      answer.help_text_for(mustache_context).should == "Northwestern is your site"

      answer.default_value = "{{site}}"
      answer.in_context(answer.default_value, mustache_context).should == "Northwestern"
      answer.default_value_for(mustache_context).should == "Northwestern"
    end
  end

  context "with translations" do
    require 'yaml'
    let(:survey){ FactoryBot.create(:survey) }
    let(:survey_section){ FactoryBot.create(:survey_section) }
    let(:survey_translation){
      FactoryBot.create(:survey_translation, :locale => :es, :translation => {
        :questions => {
          :name => {
            :answers => {
              :name => {
                :help_text => "Mi nombre es..."
              }
            }
          }
        }
      }.to_yaml)
    }
    let(:question){ FactoryBot.create(:question, :reference_identifier => "name") }
    before do
      answer.reference_identifier = "name"
      answer.help_text = "My name is..."
      answer.text = nil
      answer.question = question
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it "returns its own translation" do
      answer.translation(:es)[:help_text].should == "Mi nombre es..."
    end
    it "returns translations in views" do
      answer.help_text_for(nil, :es).should == "Mi nombre es..."
    end
    it "returns its own default values" do
      answer.translation(:de).should == {"text" => nil, "help_text" => "My name is...", "default_value" => nil}
    end
    it "returns default values in views" do
      answer.help_text_for(nil, :de).should == "My name is..."
    end
  end

  context "handling strings" do
    it "#split preserves strings" do
      answer.split(answer.text).should == "My favorite color is clear"
    end
    it "#split(:pre) preserves strings" do
      answer.split(answer.text, :pre).should == "My favorite color is clear"
    end
    it "#split(:post) preserves strings" do
      answer.split(answer.text, :post).should == ""
    end
    it "#split splits strings" do
      answer.text = "before|after|extra"
      answer.split(answer.text).should == "before|after|extra"
    end
    it "#split(:pre) splits strings" do
      answer.text = "before|after|extra"
      answer.split(answer.text, :pre).should == "before"
    end
    it "#split(:post) splits strings" do
      answer.text = "before|after|extra"
      answer.split(answer.text, :post).should == "after|extra"
    end
  end

  context "for views" do
    it "#text_for with #display_type == hidden_label" do
      answer.text = "Red"
      answer.text_for.should == "Red"
      answer.display_type = "hidden_label"
      answer.text_for.should == false
    end
    it "#default_value_for"
    it "#help_text_for"
    it "reports DOM ready #css_class from #custom_class" do
      answer.custom_class = "foo bar"
      answer.css_class.should == "form_group foo bar"
    end
    it "reports DOM ready #css_class from #custom_class and #is_exclusive" do
      answer.custom_class = "foo bar"
      answer.is_exclusive = true
      answer.css_class.should == "form_group exclusive foo bar"
    end
    it "#text_for preserves strings" do
      answer.text_for.should == "My favorite color is clear"
    end
    it "#text_for(:pre) preserves strings" do
      answer.text_for(:pre).should == "My favorite color is clear"
    end
    it "#text_for(:post) preserves strings" do
      answer.text_for(:post).should == false
    end
    it "#text_for splits strings" do
      answer.text = "before|after|extra"
      answer.text_for.should == "before|after|extra"
    end
    it "#text_for(:pre) splits strings" do
      answer.text = "before|after|extra"
      answer.text_for(:pre).should == "before"
    end
    it "#text_for(:post) splits strings" do
      answer.text = "before|after|extra"
      answer.text_for(:post).should == "after|extra"
    end
  end
end
