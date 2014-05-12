require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveyorHelper do
  context "numbering" do
    it "should return the question text with number, except for labels, dependencies, images, and grouped questions" do
      q1 = FactoryGirl.create(:question)
      q2 = FactoryGirl.create(:question, :display_type => "label")
      q3 = FactoryGirl.create(:question, :dependency => FactoryGirl.create(:dependency))
      q4 = FactoryGirl.create(:question, :display_type => "image", :text => "something.jpg")
      q5 = FactoryGirl.create(:question, :question_group => FactoryGirl.create(:question_group))
      helper.q_text(q1).should == "<span class='qnum'>1) </span>#{q1.text}"
      helper.q_text(q2).should == q2.text
      helper.q_text(q3).should == q3.text
      helper.q_text(q4).should =~ /<img alt="Something" src="\/(images|assets)\/something\.jpg" \/>/
      helper.q_text(q5).should == q5.text
    end
  end

  context "with mustache text substitution" do
    require 'mustache'
    let(:mustache_context){ Class.new(::Mustache){ def site; "Northwestern"; end; def somethingElse; "something new"; end; def group; "NUBIC"; end } }
    it "substitues values into Question#text" do
      q1 = FactoryGirl.create(:question, :text => "You are in {{site}}")
      label = FactoryGirl.create(:question, :display_type => "label", :text => "Testing {{somethingElse}}")
      helper.q_text(q1, mustache_context).should == "<span class='qnum'>1) </span>You are in Northwestern"
      helper.q_text(label, mustache_context).should == "Testing something new"
    end
  end

  context "response methods" do
    it "should find or create responses, with index" do
      q1 = FactoryGirl.create(:question, :answers => [a = FactoryGirl.create(:answer, :text => "different")])
      q2 = FactoryGirl.create(:question, :answers => [b = FactoryGirl.create(:answer, :text => "strokes")])
      q3 = FactoryGirl.create(:question, :answers => [c = FactoryGirl.create(:answer, :text => "folks")])
      rs = FactoryGirl.create(:response_set, :responses => [r1 = FactoryGirl.create(:response, :question => q1, :answer => a), r3 = FactoryGirl.create(:response, :question => q3, :answer => c, :response_group => 1)])

      helper.response_for(rs, nil).should == nil
      helper.response_for(nil, q1).should == nil
      helper.response_for(rs, q1).should == r1
      helper.response_for(rs, q1, a).should == r1
      helper.response_for(rs, q2).attributes.reject{|k,v| k == "api_id"}.should == Response.new(:question => q2, :response_set => rs).attributes.reject{|k,v| k == "api_id"}
      helper.response_for(rs, q2, b).attributes.reject{|k,v| k == "api_id"}.should == Response.new(:question => q2, :response_set => rs).attributes.reject{|k,v| k == "api_id"}
      helper.response_for(rs, q3, c, "1").should == r3

    end
    it "should keep an index of responses" do
      helper.response_idx.should == "1"
      helper.response_idx.should == "2"
      helper.response_idx(false).should == "2"
      helper.response_idx.should == "3"
    end
    it "should translate response class into attribute" do
      helper.rc_to_attr(:string).should == :string_value
      helper.rc_to_attr(:text).should == :text_value
      helper.rc_to_attr(:integer).should == :integer_value
      helper.rc_to_attr(:float).should == :float_value
      helper.rc_to_attr(:datetime).should == :datetime_value
      helper.rc_to_attr(:date).should == :date_value
      helper.rc_to_attr(:time).should == :time_value
    end

    it "should translate response class into as" do
      helper.rc_to_as(:string).should == :string
      helper.rc_to_as(:text).should == :text
      helper.rc_to_as(:integer).should == :string
      helper.rc_to_as(:float).should == :string
      helper.rc_to_as(:datetime).should == :string
      helper.rc_to_as(:date).should == :string
      helper.rc_to_as(:time).should == :string
    end
  end

  context "overriding methods" do
    before do
      module SurveyorHelper
        include Surveyor::Helpers::SurveyorHelperMethods
        alias :old_rc_to_as :rc_to_as
        def rc_to_as(type_sym)
          case type_sym.to_s
          when /(integer|float)/ then :string
          when /(datetime)/ then :datetime
          else type_sym
          end
        end
      end
    end
    it "should translate response class into as" do
      helper.rc_to_as(:string).should == :string
      helper.rc_to_as(:text).should == :text
      helper.rc_to_as(:integer).should == :string
      helper.rc_to_as(:float).should == :string
      helper.rc_to_as(:datetime).should == :datetime  # not string
      helper.rc_to_as(:date).should == :date          # not string
      helper.rc_to_as(:time).should == :time
    end
    after do
      module SurveyorHelper
        include Surveyor::Helpers::SurveyorHelperMethods
        def rc_to_as(type_sym)
          old_rc_to_as(type_sym)
        end
      end
    end
  end

  # run this context after 'overriding methods'
  context "post override test" do
    # Sanity check
    it "should translate response class into as after override" do
      helper.rc_to_as(:datetime).should == :string  # back to string
      helper.rc_to_as(:date).should == :string      # back to string
    end
  end
end
