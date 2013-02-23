require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveySection do
    let(:survey_section){ Factory(:survey_section) }

  context "when creating" do
    it "is invalid without #title" do
      survey_section.title = nil
      survey_section.should have(1).error_on(:title)
    end
    it "protects #api_id" do
      saved_attrs = survey_section.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { survey_section.update_attributes(:api_id => "NEW") }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        survey_section.attributes = {:api_id => "NEW"} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      survey_section.attributes.should == saved_attrs
    end
    it "protects #created_at" do
      saved_attrs = survey_section.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { survey_section.update_attributes(:created_at => 3.days.ago) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        survey_section.attributes = {:created_at => 3.days.ago} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      survey_section.attributes.should == saved_attrs
    end
    it "protects #updated_at" do
      saved_attrs = survey_section.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { survey_section.update_attributes(:updated_at => 3.hours.ago) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        survey_section.attributes = {:updated_at => 3.hours.ago} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      survey_section.attributes.should == saved_attrs
    end
  end

  context "with questions" do
    let(:question_1){ Factory(:question, :survey_section => survey_section, :display_order => 3, :text => "Peep")}
    let(:question_2){ Factory(:question, :survey_section => survey_section, :display_order => 1, :text => "Little")}
    let(:question_3){ Factory(:question, :survey_section => survey_section, :display_order => 2, :text => "Bo")}
    before do
      [question_1, question_2, question_3].each{|q| survey_section.questions << q }
    end
    it{ survey_section.should have(3).questions}
    it "gets questions in order" do      
      survey_section.questions.should == [question_2, question_3, question_1]
      survey_section.questions.map(&:display_order).should == [1,2,3]
    end
    it "deletes child questions when deleted" do
      question_ids = survey_section.questions.map(&:id)
      survey_section.destroy
      question_ids.each{|id| Question.find_by_id(id).should be_nil}
    end
  end
end
