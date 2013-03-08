# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer do
  let(:answer){ Factory(:answer) }

  context "when creating" do
    it { answer.should be_valid }
    it "deletes validation when deleted" do
      v_id = Factory(:validation, :answer => answer).id
      answer.destroy
      Validation.find_by_id(v_id).should be_nil
    end
    it "protects #api_id" do
      saved_attrs = answer.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { answer.update_attributes(:api_id => "NEW") }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        answer.attributes = {:api_id => "NEW"} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      answer.attributes.should == saved_attrs
    end
    it "protects #created_at" do
      saved_attrs = answer.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { answer.update_attributes(:created_at => 3.days.ago) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        answer.attributes = {:created_at => 3.days.ago} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      answer.attributes.should == saved_attrs
    end
    it "protects #updated_at" do
      saved_attrs = answer.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { answer.update_attributes(:updated_at => 3.hours.ago) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        answer.attributes = {:updated_at => 3.hours.ago} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      answer.attributes.should == saved_attrs
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
    let(:survey){ Factory(:survey) }
    let(:survey_section){ Factory(:survey_section) }
    let(:survey_translation){
      Factory(:survey_translation, :locale => :es, :translation => {
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
    let(:question){ Factory(:question, :reference_identifier => "name") }
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
    let(:asset_directory){ asset_pipeline_enabled? ? "assets" : "images" }
    before do
      ActionController::Base.helpers.config.assets_dir = "public" unless asset_pipeline_enabled?
    end
    it "#text_for with #display_type == image" do
      answer.text = "rails.png"
      answer.display_type = :image
      answer.text_for.should == %(<img alt="Rails" src="/#{asset_directory}/rails.png" />)
    end
    it "#text_for with #display_type == hidden_label" do
      answer.text = "Red"
      answer.text_for.should == "Red"
      answer.display_type = "hidden_label"
      answer.text_for.should == ""
    end
    it "#default_value_for"
    it "#help_text_for"
    it "reports DOM ready #css_class from #custom_class" do
      answer.custom_class = "foo bar"
      answer.css_class.should == "foo bar"
    end
    it "reports DOM ready #css_class from #custom_class and #is_exclusive" do
      answer.custom_class = "foo bar"
      answer.is_exclusive = true
      answer.css_class.should == "exclusive foo bar"
    end
    it "#text_for preserves strings" do
      answer.text_for.should == "My favorite color is clear"
    end
    it "#text_for(:pre) preserves strings" do
      answer.text_for(:pre).should == "My favorite color is clear"
    end
    it "#text_for(:post) preserves strings" do
      answer.text_for(:post).should == ""
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