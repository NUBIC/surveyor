require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Answer do
  let(:answer){ Factory(:answer) }

  context "when creating" do
    it { answer.should be_valid }
    it "reports DOM ready #css_class" do
      answer.custom_class = "foo bar"
      answer.css_class.should == "foo bar"
      answer.is_exclusive = true
      answer.css_class.should == "exclusive foo bar"
    end
    it "splits #text" do
      answer.text = "before|after|extra"
      answer.split_or_hidden_text.should == "before|after|extra"
      answer.split_or_hidden_text(:pre).should == "before"
      answer.split_or_hidden_text(:post).should == "after|extra"
    end
    it "hides labels when #display_type == hidden_label" do
      answer.text = "Red"
      answer.split_or_hidden_text.should == "Red"
      answer.display_type = "hidden_label"
      answer.split_or_hidden_text.should == ""
    end
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
      answer.split_or_hidden_text(nil, mustache_context).should == "You are in Northwestern"
    end
  end
end