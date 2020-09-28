# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer do
  let(:answer){ FactoryBot.create(:answer) }

  context "when creating" do
    it { expect(answer).to be_valid }
    it "deletes validation when deleted" do
      v_id = FactoryBot.create(:validation, :answer => answer).id
      answer.destroy
      expect(Validation.find_by_id(v_id)).to be_nil
    end

    it 'should check qualifying logic' do
      ['must', 'may', 'reject'].each do |ql|
        answer.qualify_logic = ql
        expect(answer.save).to be(true)
      end

      answer.qualify_logic = nil
      expect(answer.save).to be(false)
      expect(answer).to have(1).error_on(:qualify_logic)

      answer.qualify_logic = ''
      expect(answer.save).to be(false)
      expect(answer).to have(1).error_on(:qualify_logic)

      answer.qualify_logic = 'accept'
      expect(answer.save).to be(false)
      expect(answer).to have(1).error_on(:qualify_logic)
    end
  end

  context "with mustache text substitution" do
    require 'mustache'
    let(:mustache_context){ Class.new(::Mustache){ def site; "Northwestern"; end; def foo; "bar"; end } }
    it "subsitutes Mustache context variables" do
      answer.text = "You are in {{site}}"
      expect(answer.in_context(answer.text, mustache_context)).to eq("You are in Northwestern")
      expect(answer.text_for(nil, mustache_context)).to eq("You are in Northwestern")

      answer.help_text = "{{site}} is your site"
      expect(answer.in_context(answer.help_text, mustache_context)).to eq("Northwestern is your site")
      expect(answer.help_text_for(mustache_context)).to eq("Northwestern is your site")

      answer.default_value = "{{site}}"
      expect(answer.in_context(answer.default_value, mustache_context)).to eq("Northwestern")
      expect(answer.default_value_for(mustache_context)).to eq("Northwestern")
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
      expect(answer.translation(:es)[:help_text]).to eq("Mi nombre es...")
    end
    it "returns translations in views" do
      expect(answer.help_text_for(nil, :es)).to eq("Mi nombre es...")
    end
    it "returns its own default values" do
      expect(answer.translation(:de)).to eq({"text" => nil, "help_text" => "My name is...", "default_value" => nil})
    end
    it "returns default values in views" do
      expect(answer.help_text_for(nil, :de)).to eq("My name is...")
    end
  end

  context "handling strings" do
    it "#split preserves strings" do
      expect(answer.split(answer.text)).to eq("My favorite color is clear")
    end
    it "#split(:pre) preserves strings" do
      expect(answer.split(answer.text, :pre)).to eq("My favorite color is clear")
    end
    it "#split(:post) preserves strings" do
      expect(answer.split(answer.text, :post)).to eq("")
    end
    it "#split splits strings" do
      answer.text = "before|after|extra"
      expect(answer.split(answer.text)).to eq("before|after|extra")
    end
    it "#split(:pre) splits strings" do
      answer.text = "before|after|extra"
      expect(answer.split(answer.text, :pre)).to eq("before")
    end
    it "#split(:post) splits strings" do
      answer.text = "before|after|extra"
      expect(answer.split(answer.text, :post)).to eq("after|extra")
    end
  end

  context "for views" do
    it "#text_for with #display_type == hidden_label" do
      answer.text = "Red"
      expect(answer.text_for).to eq("Red")
      answer.display_type = "hidden_label"
      expect(answer.text_for).to eq(false)
    end
    it "#default_value_for"
    it "#help_text_for"
    it "reports DOM ready #css_class from #custom_class" do
      answer.custom_class = "foo bar"
      expect(answer.css_class).to eq("form_group foo bar")
    end
    it "reports DOM ready #css_class from #custom_class and #is_exclusive" do
      answer.custom_class = "foo bar"
      answer.is_exclusive = true
      expect(answer.css_class).to eq("form_group exclusive foo bar")
    end
    it "#text_for preserves strings" do
      expect(answer.text_for).to eq("My favorite color is clear")
    end
    it "#text_for(:pre) preserves strings" do
      expect(answer.text_for(:pre)).to eq("My favorite color is clear")
    end
    it "#text_for(:post) preserves strings" do
      expect(answer.text_for(:post)).to eq(false)
    end
    it "#text_for splits strings" do
      answer.text = "before|after|extra"
      expect(answer.text_for).to eq("before|after|extra")
    end
    it "#text_for(:pre) splits strings" do
      answer.text = "before|after|extra"
      expect(answer.text_for(:pre)).to eq("before")
    end
    it "#text_for(:post) splits strings" do
      answer.text = "before|after|extra"
      expect(answer.text_for(:post)).to eq("after|extra")
    end
  end
end
