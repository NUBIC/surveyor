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
  describe 'reference checking' do
    it 'accepts Answer#reference_identifier via underscore or hash syntax' do
      survey_text = <<END
  survey "Numbers" do
    section_one "One" do
      q_1 "Select a number", :pick => :one
      a "One", {:reference_identifier => "1"}
      a_2 "Two"
      a_3 "Three"

      label_2 "One is the loneliest number..."
      dependency :rule => "A"
      condition_A :q_1, "==", {:answer_reference => "1"}

      label_3 "Two can be as bad as one..."
      dependency :rule => "A"
      condition_A :q_1, "==", {:answer_reference => "2"}

      label_4 "that you'll ever do"
      dependency :rule => "A"
      condition_A :q_1, "==", :a_1

      label_5 "it's the loneliest number since the number one"
      dependency :rule => "A"
      condition_A :q_1, "==", :a_2
    end
  end
END
      survey = Surveyor::Parser.new.parse(survey_text)
      survey.is_a?(Survey).should == true
    end

  end

  describe 'translations' do

    it 'should produce the survey text for :default locale' do
      survey_text = <<END
  survey "One language is never enough" do
   translations :en => :default, :es =>{'questions' => {'name' =>{ 'text' => '¡Hola!'}}}
    section_one "One" do
      label_name "Hello!"
    end
  end
END
      survey = Surveyor::Parser.new.parse(survey_text)
      survey.is_a?(Survey).should == true
      survey.translations.size.should == 2
      question = survey.sections.first.questions.first
      question.translation(:en)[:text].should == "Hello!"
      question.translation(:es)[:text].should == "¡Hola!"
    end


    it 'should raise an error w/o :default locale' do
      survey_text = <<END
  survey "One language is never enough" do
   translations :es =>{'questions' => {'name' =>{ 'text' => '¡Hola!'}}}
    section_one "One" do
      label_name "Hello!"
    end
  end
END
      s = Survey.all.size
      expect {survey = Surveyor::Parser.new.parse(survey_text)}.to raise_error
      Survey.all.size.should == s
    end


    it 'should allow multiple default locales' do
      survey_text = <<END
  survey "Just don't talk about tyres" do
   translations :'en-US' => :default, :'en-GB' => :default, :es =>{'questions' => {'name' =>{'text' => '¡Hola!'}}}
   section_one "One" do
     label_name "Hello!"
   end
  end
END

      survey = Surveyor::Parser.new.parse(survey_text)
      survey.is_a?(Survey).should == true
      survey.translations.size.should == 3
      question = survey.sections.first.questions.first
      question.translation(:'en-US')[:text].should == "Hello!"
      question.translation(:'en-GB')[:text].should == "Hello!"
      question.translation(:es)[:text].should == "¡Hola!"
    end

    context 'when a translation is specified as a Hash' do
      it 'should should treat the hash as an inline translation' do
        survey_text = <<END
survey "One language is never enough" do
      translations :en => :default, :es => {"title"=>"Un idioma nunca es suficiente", "survey_sections"=>{"one"=>{"title"=>"Uno"}}, "question_groups"=>{"hello"=>{"text"=>"¡Hola!"}}, "questions"=>{"name"=>{"text"=>"¿Cómo se llama Usted?", "answers"=>{"name"=>{"help_text"=>"Mi nombre es..."}}}}}
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
        survey.translations.size.should == 2
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
      translations :es =>'#{File.basename(translation_temp_file.path)}', :en => :default
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
      translations :es =>'#{File.basename(translation_temp_file.path)}', :en => :default
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
end
