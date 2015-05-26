# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::Parser do
  let(:parser){ Surveyor::Parser.new }
  it "should return a survey object" do
    Surveyor::Parser.new.parse("survey 'hi' do\n end").is_a?(Survey).should be_true
  end
  context "basic questions" do
    include_context "favorites"
    it "parses" do
      expect(Survey.count).to eq(1)
      expect(SurveySection.count).to eq(2)
      expect(Question.count).to eq(4)
      expect(Answer.count).to eq(9)
      surveys =   [{title: "Favorites", display_order: 0}]
      sections =  [{title: "Colors", reference_identifier: "colors", display_order: 0},
                   {title: "Numbers", reference_identifier: "numbers", display_order: 1}]
      questions = [{reference_identifier: nil, text: "These questions are examples of the basic supported input types", pick: "none", display_type: "label", display_order: 0},
                   {reference_identifier: "1", text: "What is your favorite color?", pick: "one", display_type: "default", display_order: 1},
                   {reference_identifier: "2b", text: "Choose the colors you don't like", pick: "any", display_type: "default", display_order: 2},
                   {reference_identifier: "fire_engine", text: "What is the best color for a fire engine?",display_type: "default", display_order: 3}]
      answers_1 = [{reference_identifier: "r", data_export_identifier: "1", text: "red", response_class: "answer", display_order: 0},
                   {reference_identifier: "b", data_export_identifier: "2", text: "blue", response_class: "answer", display_order: 1},
                   {reference_identifier: "g", data_export_identifier: "3", text: "green", response_class: "answer", display_order: 2},
                   {reference_identifier: nil, text: "Other", response_class: "answer", display_order: 3}]
      answers_2 = [{reference_identifier: "1", text: "orange", response_class: "answer", display_order: 1},
                   {reference_identifier: "2", text: "purple", response_class: "answer", display_order: 2},
                   {reference_identifier: "3", text: "brown", response_class: "answer", display_order: 0},
                   {reference_identifier: nil, text: "Omit", response_class: "answer", display_order: 3}]
      surveys.each{|attrs| attrs.each{|k,v| expect(Survey.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      sections.each{|attrs| attrs.each{|k,v| expect(SurveySection.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      questions.each{|attrs| attrs.each{|k,v| expect(Question.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      answers_1.each{|attrs| attrs.each{|k,v| expect(Question.where(display_order: 1).first.answers.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      answers_2.each{|attrs| attrs.each{|k,v| expect(Question.where(display_order: 2).first.answers.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
    end
  end
  context "complex questions" do
    include_context "feelings"
    it "parses" do
      expect(Survey.count).to eq(1)
      expect(QuestionGroup.count).to eq(3)
      expect(Question.count).to eq(10)
      expect(Answer.count).to eq(34)
      surveys = [{title: "Feelings", display_order: 0}]
      question_groups = [{text: "Tell us how you feel today", display_type: "grid", reference_identifier: "today"},
                         {text: "How interested are you in the following?", display_type: "grid", reference_identifier: "events"},
                         {text: "Tell us about your family", display_type: "repeater", reference_identifier: "family"}]
      dropdown_question_attributes = {text: "Relation", pick: "one"}
      grid_questions = QuestionGroup.where(reference_identifier: "today").first.questions
      grid_answers_1 = [{text: "-2", display_order: 0},
                        {text: "-1", display_order: 1},
                        {text: "0", display_order: 2},
                        {text: "1", display_order: 3},
                        {text: "2", display_order: 4}]
      surveys.each{|attrs| attrs.each{|k,v| expect(Survey.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      question_groups.each{|attrs| attrs.each{|k,v| expect(QuestionGroup.where(reference_identifier: attrs[:reference_identifier]).first[k]).to eq(v)} }
      grid_questions.each{|question| grid_answers_1.each{|attrs| attrs.each{|k,v| expect(question.answers.where(display_order: attrs[:display_order]).first[k]).to eq(v)} } }
      dropdown_question_attributes.each{|k,v| expect(Question.where(display_type: "dropdown").first[k]).to eq(v)}
    end
    it "clears grid answers" do
      grid_answers_1 = [{text: "-2", display_order: 0},
                        {text: "-1", display_order: 1},
                        {text: "0", display_order: 2},
                        {text: "1", display_order: 3},
                        {text: "2", display_order: 4}]
      grid_answers_2 = [{text: "indifferent", display_order: 0},
                        {text: "neutral", display_order: 1},
                        {text: "interested", display_order: 2}]
    end
  end
  context "depdencies and validations" do
    include_context "lifestyle"
    it "parses" do
      expect(Survey.count).to eq(1)
      expect(SurveySection.count).to eq(2)
      expect(QuestionGroup.count).to eq(1)
      expect(Question.count).to eq(10)
      expect(Answer.count).to eq(12)
      expect(Dependency.count).to eq(6)
      expect(DependencyCondition.count).to eq(6)
      expect(Validation.count).to eq(2)
      expect(ValidationCondition.count).to eq(2)
      depdendencies = [{rule: "B", question_reference_identifier: "copd_sh_1b"},
                       {rule: "C", question_reference_identifier: "copd_sh_1ba"},
                       {rule: "D", question_reference_identifier: "copd_sh_1bb"},
                       {rule: "Q", question_group_reference_identifier: "one_pet"},
                       {rule: "R", question_reference_identifier: "very_creative"},
                       {rule: "S", question_reference_identifier: "oh_my"}]
      depdendencies.each{|attrs| (expect(Dependency.where(rule: attrs[:rule]).first.question.reference_identifier).to eq(attrs[:question_reference_identifier])) if attrs[:question_reference_identifier] }
      depdendencies.each{|attrs| (expect(Dependency.where(rule: attrs[:rule]).first.question_group.reference_identifier).to eq(attrs[:question_group_reference_identifier])) if attrs[:question_group_reference_identifier] }
      dependency_conditions = [{rule_key: "B", question_reference_identifier: "copd_sh_1", answer_reference_identifier: "1"},
                               {rule_key: "C", question_reference_identifier: "copd_sh_1b", answer_reference_identifier: "quit"},
                               {rule_key: "D", question_reference_identifier: "copd_sh_1b", answer_reference_identifier: "current_as_of_one_month"},
                               {rule_key: "Q", question_reference_identifier: "pets", answer_reference_identifier: "number"},
                               {rule_key: "R", question_reference_identifier: "favorite_pet", answer_reference_identifier: "name"},
                               {rule_key: "S", question_reference_identifier: "dream_pet"}]
      dependency_conditions.each{|attrs| expect(DependencyCondition.where(rule_key: attrs[:rule_key]).first.question.reference_identifier).to eq(attrs[:question_reference_identifier]) }
      dependency_conditions.each{|attrs| (expect(DependencyCondition.where(rule_key: attrs[:rule_key]).first.answer.reference_identifier).to eq(attrs[:answer_reference_identifier])) if attrs[:answer_reference_identifier] }
    end
  end
  context "translations" do
    it 'should produce the survey text for :default locale' do
      survey_text = %{
        survey "One language is never enough" do
         translations :en => :default, :es =>{'questions' => {'name' =>{ 'text' => '¡Hola!'}}}
          section_one "One" do
            label_name "Hello!"
          end
        end
      }
      survey = Surveyor::Parser.new.parse(survey_text)
      survey.is_a?(Survey).should == true
      survey.translations.size.should == 2
      question = survey.sections.first.questions.first
      question.translation(:en)[:text].should == "Hello!"
      question.translation(:es)[:text].should == "¡Hola!"
    end
    it 'should raise an error w/o :default locale' do
      survey_text = %{
        survey "One language is never enough" do
         translations :es =>{'questions' => {'name' =>{ 'text' => '¡Hola!'}}}
          section_one "One" do
            label_name "Hello!"
          end
        end
      }
      s = Survey.all.size
      expect {survey = Surveyor::Parser.new.parse(survey_text)}.to raise_error
      Survey.all.size.should == s
    end
    it 'should allow multiple default locales' do
      survey_text = %{
        survey "Just don't talk about tyres" do
         translations :'en-US' => :default, :'en-GB' => :default, :es =>{'questions' => {'name' =>{'text' => '¡Hola!'}}}
         section_one "One" do
           label_name "Hello!"
         end
        end
      }
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
        survey_text = %{
          survey "One language is never enough" do
            translations :en => :default, :es => {"title"=>"Un idioma nunca es suficiente", "survey_sections"=>{"one"=>{"title"=>"Uno"}}, "question_groups"=>{"hello"=>{"text"=>"¡Hola!"}}, "questions"=>{"name"=>{"text"=>"¿Cómo se llama Usted?", "answers"=>{"name"=>{"help_text"=>"Mi nombre es..."}}}}}
            section_one "One" do
              g_hello "Hello" do
                q_name "What is your name?"
                a_name :string, :help_text => "My name is..."
              end
            end
          end
        }
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
              survey_text = %{
                survey "One language is never enough" do
                  translations :es =>'#{File.basename(translation_temp_file.path)}', :en => :default
                  section_one "One" do
                    g_hello "Hello" do
                      q_name "What is your name?"
                      a_name :string, :help_text => "My name is..."
                    end
                  end
                end
              }
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
            survey_text = %{
              survey "One language is never enough" do
                translations :es =>'#{File.basename(translation_temp_file.path)}', :en => :default
                section_one "One" do
                  g_hello "Hello" do
                    q_name "What is your name?"
                    a_name :string, :help_text => "My name is..."
                  end
                end
              end
            }
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
  context "quizzes" do
    include_context "numbers"
    it "parses" do
      expect(Survey.count).to eq(1)
      expect(SurveySection.count).to eq(2)
      expect(Question.count).to eq(3)
      expect(Answer.count).to eq(11)
      surveys =   [{title: "Numbers", display_order: 0}]
      sections =  [{title: "Addition", reference_identifier: nil, display_order: 0},
                   {title: "Literature", reference_identifier: nil, display_order: 1}]
      questions = [{reference_identifier: "1", text: "What is one plus one?", pick: "one", display_type: "default", display_order: 0},
                   {reference_identifier: "2", text: "What is five plus one?", pick: "one", display_type: "default", display_order: 1},
                   {reference_identifier: "the_answer", text: "What is the 'Answer to the Ultimate Question of Life, The Universe, and Everything'", pick: "one", display_type: "default", display_order: 0}]
      answers_1 = [{reference_identifier: "1", text: "1", response_class: "answer", display_order: 0},
                   {reference_identifier: "2", text: "2", response_class: "answer", display_order: 1},
                   {reference_identifier: "3", text: "3", response_class: "answer", display_order: 2},
                   {reference_identifier: "4", text: "4", response_class: "answer", display_order: 3}]
      answers_2 = [{reference_identifier: "5", text: "five", response_class: "answer", display_order: 0},
                   {reference_identifier: "6", text: "six", response_class: "answer", display_order: 1},
                   {reference_identifier: "7", text: "seven", response_class: "answer", display_order: 2},
                   {reference_identifier: "8", text: "eight", response_class: "answer", display_order: 3}]
      correct_answers = [{question_reference_identifier: "1", correct_answer_text: "2"},
                         {question_reference_identifier: "2", correct_answer_text: "six"},
                         {question_reference_identifier: "the_answer", correct_answer_text: "42"}]
      surveys.each{|attrs| attrs.each{|k,v| expect(Survey.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      sections.each{|attrs| attrs.each{|k,v| expect(SurveySection.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      questions.each{|attrs| attrs.each{|k,v| expect(Question.where(reference_identifier: attrs[:reference_identifier]).first[k]).to eq(v)} }
      answers_1.each{|attrs| attrs.each{|k,v| expect(Question.where(reference_identifier: "1").first.answers.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      answers_2.each{|attrs| attrs.each{|k,v| expect(Question.where(reference_identifier: "2").first.answers.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
      correct_answers.each{|attrs| expect(Question.where(reference_identifier: attrs[:question_reference_identifier]).first.correct_answer.text).to eq(attrs[:correct_answer_text]) }
    end
  end
  context "mandatory" do
    it "parses" do
      survey_text = %{
        survey "Chores", default_mandatory: true do
          section "Morning" do
            q "Did you take out the trash", pick: :one
            a "Yes"
            a "No"

            q "Did you do the laundry", pick: :one
            a "Yes"
            a "No"

            q "Optional comments", is_mandatory: false
            a :string
          end
        end
      }
      survey = Surveyor::Parser.new.parse(survey_text)
      expect(Survey.count).to eq(1)
      expect(SurveySection.count).to eq(1)
      expect(Question.count).to eq(3)
      questions = [{display_order: 0, text: "Did you take out the trash", is_mandatory: true},
                   {display_order: 1, text: "Did you do the laundry", is_mandatory: true},
                   {display_order: 2, text: "Optional comments", is_mandatory: false}]
      questions.each{|attrs| attrs.each{|k,v| expect(Question.where(display_order: attrs[:display_order]).first[k]).to eq(v)} }
    end
  end
  context "failures" do
    it "typos in blocks" do
      survey_text = %q{
        survey "Basics" do
          sectionals "Typo" do
          end
        end
      }
      expect { Surveyor::Parser.parse(survey_text) }.to raise_error(Surveyor::ParserError, /\"sectionals\" is not a surveyor method./)
    end
    it "bad references" do
      survey_text = %q{
        survey "Refs" do
          section "Bad" do
            q_watch "Do you watch football?", :pick => :one
            a_1 "Yes"
            a_2 "No"

            q "Do you like the replacement refs?", :pick => :one
            dependency :rule => "A or B"
            condition_A :q_1, "==", :a_1
            condition_B :q_watch, "==", :b_1
            a "Yes"
            a "No"
          end
        end
      }
      expect { Surveyor::Parser.parse(survey_text) }.to raise_error(Surveyor::ParserError, /Bad references: q_1; q_1, a_1; q_watch, a_b_1/)
    end
    it "repeated references" do
      survey_text = %q{
        survey "Refs" do
          section "Bad" do
            q_watch "Do you watch football?", :pick => :one
            a_1 "Yes"
            a_1 "No"

            q_watch "Do you watch baseball?", :pick => :one
            a_yes "Yes"
            a_no  "No"

            q "Do you like the replacement refs?", :pick => :one
            dependency :rule => "A or B"
            condition_A :q_watch, "==", :a_1
            a "Yes"
            a "No"
          end
        end
      }
      expect { Surveyor::Parser.parse(survey_text) }.to raise_error(Surveyor::ParserError, /Duplicate references: q_watch, a_1; q_watch/)
    end
    it "with Rails validation errors" do
      survey_text = %q{
        survey do
          section "Usage" do
            q_PLACED_BAG_1 "Is the bag placed?", :pick => :one
            a_1 "Yes"
            a_2 "No"
            a_3 "Refused"
          end
        end
      }
      expect { Surveyor::Parser.parse(survey_text) }.to raise_error(Surveyor::ParserError, /Survey not saved: Title can't be blank/)
    end
    it "bad shortcuts" do
      survey_text = %q{
        survey "shortcuts" do
          section "Bad" do
            quack "Do you like ducks?", :pick => :one
            a_1 "Yes"
            a_1 "No"
          end
        end
      }
      expect { Surveyor::Parser.parse(survey_text) }.to raise_error(Surveyor::ParserError, /\"quack\" is not a surveyor method./)
    end
  end
  context "helper methods" do
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
  end
end
