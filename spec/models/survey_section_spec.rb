# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveySection do
    let(:survey_section){ FactoryGirl.create(:survey_section) }

  context "when creating" do
    it "is invalid without #title" do
      survey_section.title = nil
      survey_section.should have(1).error_on(:title)
    end
  end

  context "with questions" do
    let(:question_1){ FactoryGirl.create(:question, :survey_section => survey_section, :display_order => 3, :text => "Peep")}
    let(:question_2){ FactoryGirl.create(:question, :survey_section => survey_section, :display_order => 1, :text => "Little")}
    let(:question_3){ FactoryGirl.create(:question, :survey_section => survey_section, :display_order => 2, :text => "Bo")}
    before do
      [question_1, question_2, question_3].each{|q| survey_section.questions << q }
    end
    it{ survey_section.should have(3).questions}
    it "gets questions in order" do
      survey_section.questions.order("display_order asc").should == [question_2, question_3, question_1]
      survey_section.questions.order("display_order asc").map(&:display_order).should == [1,2,3]
    end
    it "deletes child questions when deleted" do
      question_ids = survey_section.questions.map(&:id)
      survey_section.destroy
      question_ids.each{|id| Question.find_by_id(id).should be_nil}
    end
  end

  context "with translations" do
    require 'yaml'
    let(:survey){ FactoryGirl.create(:survey) }
    let(:survey_translation){
      FactoryGirl.create(:survey_translation, :locale => :es, :translation => {
        :survey_sections => {
          :one => {
            :title => "Uno"
          }
        }
      }.to_yaml)
    }
    before do
      survey_section.reference_identifier = "one"
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it "returns its own translation" do
      YAML.load(survey_translation.translation).should_not be_nil
      survey_section.translation(:es)[:title].should == "Uno"
    end
    it "returns its own default values" do
      survey_section.translation(:de).should == {"title" => survey_section.title, "description" => survey_section.description}
    end
  end

  describe 'completed' do
    let!( :survey ) { FactoryGirl.create( :survey ) }
    let!( :empty_section ) { FactoryGirl.create( :survey_section, :survey => survey ) }

    let!( :no_mandatory_section ) { FactoryGirl.create( :survey_section, :survey => survey ) }
    let!( :no_mandatory_optional_question ) {
      FactoryGirl.create( :question,
        :survey_section_id => no_mandatory_section.id,
        :is_mandatory => false
      )
    }
    let!( :no_mandatory_optional_answer ) {
      FactoryGirl.create( :answer,
        :question => no_mandatory_optional_question,
        :response_class => :string
      )
    }

    let!( :mixed_section ) { FactoryGirl.create( :survey_section, :survey => survey ) }
    let!( :mixed_optional_question_1 ) {
      FactoryGirl.create( :question,
        :survey_section_id => mixed_section.id,
        :is_mandatory => false
      )
    }
    let!( :mixed_optional_answer_1 ) {
      FactoryGirl.create( :answer,
        :question => mixed_optional_question_1,
        :response_class => :string
      )
    }
    let!( :mixed_optional_question_2 ) {
      FactoryGirl.create( :question,
        :survey_section_id => mixed_section.id,
        :is_mandatory => false
      )
    }
    let!( :mixed_optional_answer_2 ) {
      FactoryGirl.create( :answer,
        :question => mixed_optional_question_2,
        :response_class => :string
      )
    }
    let!( :mixed_mandatory_question_1 ) {
      FactoryGirl.create( :question,
        :survey_section_id => mixed_section.id,
        :is_mandatory => true
      )
    }
    let!( :mixed_mandatory_answer_1 ) {
      FactoryGirl.create( :answer,
        :question => mixed_mandatory_question_1,
        :response_class => :string
      )
    }
    let!( :mixed_mandatory_question_2 ) {
      FactoryGirl.create( :question,
        :survey_section_id => mixed_section.id,
        :is_mandatory => true
      )
    }
    let!( :mixed_mandatory_answer_2 ) {
      FactoryGirl.create( :answer,
        :question => mixed_mandatory_question_2,
        :response_class => :string
      )
    }

    let!( :dependency_section ) { FactoryGirl.create( :survey_section, :survey => survey ) }
    let!( :dependency_mandatory_question ) {
      FactoryGirl.create( :question,
        :survey_section_id => dependency_section.id,
        :is_mandatory => true
      )
    }
    let!( :dependency_mandatory_answer ) {
      FactoryGirl.create( :answer,
        :question => dependency_mandatory_question,
        :response_class => :string
      )
    }
    let!( :dependency_mandatory_dependency ) {
      FactoryGirl.create( :dependency,
        :question => dependency_mandatory_question
      )
    }
    let!( :dependency_mandatory_dependency_condition ) {
      FactoryGirl.create( :dependency_condition,
        :dependency => dependency_mandatory_dependency,
        :question_id => mixed_mandatory_question_1.id,
        :answer_id => mixed_mandatory_answer_1.id,
        :string_value => "answer"
      )
    }

    let!( :new_set ) { ResponseSet.create( :survey => survey ) }

    it 'should indicate that a section is complete if there are no questions in the section' do
      empty_section.completed?( new_set ).should be true
    end

    it 'should indicate that a section is complete if there are no mandatory questions in the section' do
      no_mandatory_section.completed?( new_set ).should be true

      new_set.responses.build(
        :question_id => no_mandatory_optional_question.id,
        :answer_id => no_mandatory_optional_answer.id,
        :string_value => "answer"
      )
      new_set.save.should be true
      no_mandatory_section.completed?( new_set ).should be true
    end

    it 'should indicate that a section is not complete if there are no responses for a mandatory question in the section' do
      mixed_section.completed?( new_set ).should be false
    end

    it 'should indicate that a section is complete if the mandatory questions in the section are complete' do
      new_set.responses.build(
        :question_id => mixed_mandatory_question_1.id,
        :answer_id => mixed_mandatory_answer_1.id,
        :string_value => "answer"
      )
      new_set.responses.build(
        :question_id => mixed_mandatory_question_2.id,
        :answer_id => mixed_mandatory_answer_2.id,
        :string_value => "answer"
      )
      new_set.save.should be true
      mixed_section.completed?( new_set ).should be true
    end

    it 'should indicate that a section is not complete if only some mandatory questions in the section are complete' do
      mixed_section.completed?( new_set ).should be false

      new_set.responses.build(
        :question_id => mixed_mandatory_question_1.id,
        :answer_id => mixed_mandatory_answer_1.id,
        :string_value => "answer"
      )
      new_set.save.should be true

      mixed_section.completed?( new_set ).should be false
    end

    it 'should indicate that a section is complete if some optional questions in the section are complete' do
      mixed_section.completed?( new_set ).should be false

      new_set.responses.build(
        :question_id => mixed_optional_question_1.id,
        :answer_id => mixed_optional_answer_1.id,
        :string_value => "answer"
      )
      new_set.responses.build(
        :question_id => mixed_mandatory_question_1.id,
        :answer_id => mixed_mandatory_answer_1.id,
        :string_value => "answer"
      )
      new_set.responses.build(
        :question_id => mixed_mandatory_question_2.id,
        :answer_id => mixed_mandatory_answer_2.id,
        :string_value => "answer"
      )
      new_set.save.should be true
      mixed_section.completed?( new_set ).should be true
    end

    it 'should indicate that a section is not complete if a mandatory question is answered with a blank value' do
      mixed_section.completed?( new_set ).should be false

      new_set.responses.build(
        :question_id => mixed_mandatory_question_1.id,
        :answer_id => mixed_mandatory_answer_1.id,
        :string_value => ""
      )
      new_set.responses.build(
        :question_id => mixed_mandatory_question_2.id,
        :answer_id => mixed_mandatory_answer_2.id,
        :string_value => "answer"
      )
      new_set.save.should be true
      mixed_section.completed?( new_set ).should be false

      new_set.responses.build(
        :question_id => mixed_mandatory_question_1.id,
        :answer_id => mixed_mandatory_answer_1.id,
        :string_value => "answer"
      )
      new_set.save.should be true
      mixed_section.completed?( new_set ).should be true
    end

    it 'should indicate that a section is complete if a mandatory question is not shown and is not answered' do
      dependency_section.completed?( new_set ).should be true

      new_set.responses.build(
        :question_id => mixed_mandatory_question_1.id,
        :answer_id => mixed_mandatory_answer_1.id,
        :string_value => "answer"
      )
      new_set.responses.build(
        :question_id => mixed_mandatory_question_2.id,
        :answer_id => mixed_mandatory_answer_2.id,
        :string_value => "answer"
      )
      new_set.save.should be true
      dependency_section.completed?( new_set ).should be false

      new_set.responses.build(
        :question_id => dependency_mandatory_question.id,
        :answer_id => dependency_mandatory_answer.id,
        :string_value => "answer"
      )
      new_set.save.should be true
      dependency_section.completed?( new_set ).should be true
    end
  end
end
