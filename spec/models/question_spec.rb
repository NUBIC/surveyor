require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question do
  let(:question){ Factory(:question) }

  context "when creating" do
    it "is invalid without #text" do
      question.text = nil
      question.should have(1).error_on :text
    end
    it "#is_mandantory == false by default" do
      question.mandatory?.should be_false
    end
    it "converts #pick to string" do
      question.pick.should == "none"
      question.pick = :one
      question.pick.should == "one"
      question.pick = nil
      question.pick.should == nil
    end
    it "splits #text" do
      question.split_text.should == "What is your favorite color?"
      question.split_text(:pre).should == "What is your favorite color?"
      question.split_text(:post).should == ""
      question.text = "before|after|extra"
      question.split_text.should == "before|after|extra"
      question.split_text(:pre).should == "before"
      question.split_text(:post).should == "after|extra"
    end
    it "#renderer == 'default' when #display_type = nil" do
      question.display_type = nil
      question.renderer.should == :default
    end
    it "has #api_id with 36 characters by default" do
      question.api_id.length.should == 36
    end
    it "#part_of_group? and #solo? are aware of question groups" do
      question.question_group = Factory(:question_group)
      question.solo?.should be_false
      question.part_of_group?.should be_true

      question.question_group = nil
      question.solo?.should be_true
      question.part_of_group?.should be_false
    end
    it "protects #api_id" do
      saved_attrs = question.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { question.update_attributes(:api_id => "NEW") }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        question.attributes = {:api_id => "NEW"} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      question.attributes.should == saved_attrs
    end
    it "protects #created_at" do
      saved_attrs = question.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { question.update_attributes(:created_at => 3.days.ago) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        question.attributes = {:created_at => 3.days.ago} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      question.attributes.should == saved_attrs
    end
    it "protects #updated_at" do
      saved_attrs = question.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        expect { question.update_attributes(:updated_at => 3.hours.ago) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        question.attributes = {:updated_at => 3.hours.ago} # Rails doesn't return false, but this will be checked in the comparison to saved_attrs
      end
      question.attributes.should == saved_attrs
    end
  end

  context "with answers" do
    let(:answer_1){ Factory(:answer, :question => question, :display_order => 3, :text => "blue")}
    let(:answer_2){ Factory(:answer, :question => question, :display_order => 1, :text => "red")}
    let(:answer_3){ Factory(:answer, :question => question, :display_order => 2, :text => "green")}
    before do
      [answer_1, answer_2, answer_3].each{|a| question.answers << a }
    end
    it{ question.should have(3).answers}
    it "gets answers in order" do      
      question.answers.should == [answer_2, answer_3, answer_1]
      question.answers.map(&:display_order).should == [1,2,3]
    end
    it "deletes child answers when deleted" do
      answer_ids = question.answers.map(&:id)
      question.destroy
      answer_ids.each{|id| Answer.find_by_id(id).should be_nil}
    end
  end

  context "with dependencies" do
    let(:response_set){ Factory(:response_set) }
    let(:dependency){ Factory(:dependency) }
    before do
      question.dependency = dependency
      dependency.stub!(:is_met?).with(response_set).and_return true
    end
    it "checks its dependency" do
      question.triggered?(response_set).should be_true
    end
    it "deletes its dependency when deleted" do
      d_id = question.dependency.id
      question.destroy
      Dependency.find_by_id(d_id).should be_nil
    end
  end

  context "with mustache text substitution" do
    require 'mustache'
    let(:mustache_context){ Class.new(::Mustache){ def site; "Northwestern"; end; def foo; "bar"; end } }
    it "subsitutes Mustache context variables" do
      question.text = "You are in {{site}}"
      question.render_question_text(mustache_context).should == "You are in Northwestern"
    end
  end

end
