# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::Parser do
  let(:parser){ Surveyor::Parser.new }
  it "should translate shortcuts into full model names" do
    parser.send(:full, "section").should == "survey_section"
    parser.send(:full, "g").should == "question_group"
    parser.send(:full, "repeater").should == "question_group"
    parser.send(:full, "label").should == "question"
    parser.send(:full, "vc").should == "validation_condition"
    parser.send(:full, "vcondition").should == "validation_condition"
  end
  it "should translate 'condition' based on context" do
    parser.send(:full, "condition").should == "dependency_condition"
    parser.send(:full, "c").should == "dependency_condition"
    parser.context[:validation] = Validation.new
    parser.send(:full, "condition").should == "validation_condition"
    parser.send(:full, "c").should == "validation_condition"
    parser.context[:validation] = nil
    parser.send(:full, "condition").should == "dependency_condition"
    parser.send(:full, "c").should == "dependency_condition"
  end
  it "should not translate bad shortcuts" do
    parser.send(:full, "quack").should == "quack"
    parser.send(:full, "grizzly").should == "grizzly"
  end
  it "should identify models that take blocks" do
    parser.send(:block_models).should == %w(survey survey_section question_group)
  end
  it "should return a survey object" do
    Surveyor::Parser.new.parse("survey 'hi' do\n end").is_a?(Survey).should be_true
  end


  context 'when a translation is specified as a Hash' do
    it 'should should treat the hash as an inline translation' do
      survey_text = <<END
survey "One language is never enough" do
      translations :es => {"title"=>"Un idioma nunca es suficiente", "survey_sections"=>{"one"=>{"title"=>"Uno"}}, "question_groups"=>{"hello"=>{"text"=>"¡Hola!"}}, "questions"=>{"name"=>{"text"=>"¿Cómo se llama Usted?", "answers"=>{"name"=>{"help_text"=>"Mi nombre es..."}}}}}
      section_one "One" do
        g_hello "Hello" do
          q_name "What is your name?"
          a_name :string, :help_text => "My name is..."
        end
      end
    end
END
      survey = Surveyor::Parser.new.parse(survey_text)
      survey.is_a?(Survey).should == true
      survey.translations.size.should == 1
      survey.translation(:es)['title'].should == "Un idioma nunca es suficiente"
    end
  end

  context 'when a translation is specified as a String' do

    context 'when the survey filename is not given' do
      it 'should look for the translation file relative to pwd' do
        Dir.mktmpdir do |dir|
          FileUtils.cd(dir) do
            translation_yaml = YAML::dump({'title' => 'Un idioma nunca es suficiente'})
            translation_temp_file = Tempfile.new('parser_spec_translation.yml',dir)
            translation_temp_file.write(translation_yaml)
            translation_temp_file.flush
            survey_text = <<END
survey "One language is never enough" do
      translations :es =>'#{File.basename(translation_temp_file.path)}'
      section_one "One" do
        g_hello "Hello" do
          q_name "What is your name?"
          a_name :string, :help_text => "My name is..."
        end
      end
    end
END
            survey_temp_file = Tempfile.new('parser_spec_survey.rb',dir)
            survey_temp_file.write(survey_text)
            survey_temp_file.flush
            Surveyor::Parser.parse(File.read(survey_temp_file.path))
            survey = Survey.where(:title=>'One language is never enough').first
            survey.nil?.should == false
            survey.translation(:es)['title'].should == "Un idioma nunca es suficiente"
          end
        end
      end
    end
    context 'when the survey filename is given' do
      it 'should look for the translation file relative to the survey directory' do
        Dir.mktmpdir do |dir|
          translation_yaml = YAML::dump({'title' => 'Un idioma nunca es suficiente'})
            translation_temp_file = Tempfile.new('surveyor:parser_spec.rb',dir)
            translation_temp_file.write(translation_yaml)
            translation_temp_file.flush
            survey_text = <<END
survey "One language is never enough" do
      translations :es =>'#{File.basename(translation_temp_file.path)}'
      section_one "One" do
        g_hello "Hello" do
          q_name "What is your name?"
          a_name :string, :help_text => "My name is..."
        end
      end
    end
END
          survey_temp_file = Tempfile.new('surveyor:parser_spec.rb',dir)
          survey_temp_file.write(survey_text)
          survey_temp_file.flush
          Surveyor::Parser.parse_file(survey_temp_file.path)
          survey = Survey.where(:title=>'One language is never enough').first
          survey.nil?.should == false
          survey.translation(:es)['title'].should == "Un idioma nunca es suficiente"
        end
      end
    end
  end
end
