require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::RedcapParser do
  before(:each) do
    # @parser = Surveyor::Parser.new
  end
  it "should require specific columns" do
    # with standard fields
    x = %w(field_units choices_or_calculations text_validation_type variable__field_name form_name  section_header field_type field_label field_note text_validation_min text_validation_max identifier branching_logic_show_field_only_if required_field)
    Surveyor::RedcapParser.new.missing_columns(x).should be_blank
    # without field_units
    y = %w(choices_or_calculations text_validation_type variable__field_name form_name  section_header field_type field_label field_note text_validation_min text_validation_max identifier branching_logic_show_field_only_if required_field)
    Surveyor::RedcapParser.new.missing_columns(y).should be_blank
    # choices_or_calculations => choices_calculations_or_slider_labels
    z = %w(field_units choices_calculations_or_slider_labels text_validation_type variable__field_name form_name  section_header field_type field_label field_note text_validation_min text_validation_max identifier branching_logic_show_field_only_if required_field)
    Surveyor::RedcapParser.new.missing_columns(z).should be_blank
    # text_validation_type => text_validation_type_or_show_slider_number
    a = %w(field_units choices_or_calculations text_validation_type_or_show_slider_number variable__field_name form_name  section_header field_type field_label field_note text_validation_min text_validation_max identifier branching_logic_show_field_only_if required_field)
    Surveyor::RedcapParser.new.missing_columns(a).should be_blank
  end
  it "should decompose dependency rules" do
    # basic
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[f1_q12]="1"').should == {:rule => "A", :components => ['[f1_q12]="1"']}
    # spacing
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[f1_q9] = "1"').should == {:rule => "A", :components => ['[f1_q9] = "1"']}
    # and
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[pre_q88]="1" and [pre_q90]="1"').should == {:rule => "A and B", :components => ['[pre_q88]="1"', '[pre_q90]="1"']}
    # or
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[second_q111]="1" or [second_q111]="3"').should == {:rule => "A or B", :components => ['[second_q111]="1"', '[second_q111]="3"']}
    # or and
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[second_q100]="1" or [second_q100]="3" and [second_q101]="1"').should == {:rule => "A or B and C", :components => ['[second_q100]="1"', '[second_q100]="3"', '[second_q101]="1"']}
    # and or
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[second_q4]="1" and [second_q11]="1" or [second_q11]="98"').should == {:rule => "A and B or C", :components => ['[second_q4]="1"', '[second_q11]="1"', '[second_q11]="98"']}
    # or or or
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[pre_q74]="1" or [pre_q74]="2" or [pre_q74]="4" or [pre_q74]="5"').should == {:rule => "A or B or C or D", :components => ['[pre_q74]="1"', '[pre_q74]="2"', '[pre_q74]="4"', '[pre_q74]="5"']}
    # and with different operator
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[f1_q15] >= 21 and [f1_q28] ="1"').should == {:rule => "A and B", :components => ['[f1_q15] >= 21', '[f1_q28] ="1"']}
  end
  it "should decompose nested dependency rules" do
    # external parenthesis
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('([pre_q74]="1" or [pre_q74]="2" or [pre_q74]="4" or [pre_q74]="5") and [pre_q76]="2"').should == {:rule => "(A or B or C or D) and E", :components => ['[pre_q74]="1"', '[pre_q74]="2"', '[pre_q74]="4"', '[pre_q74]="5"', '[pre_q76]="2"']}
    # internal parenthesis
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[f1_q10(4)]="1"').should == {:rule => "A", :components => ['[f1_q10(4)]="1"']}
    # internal and external parenthesis
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('([f1_q7(11)] = "1" or [initial_52] = "1") and [pre_q76]="2"').should == {:rule => "(A or B) and C", :components => ['[f1_q7(11)] = "1"', '[initial_52] = "1"', '[pre_q76]="2"']}
  end
  it "should decompose shortcut dependency rules" do
    # 'or' on the right of the operator
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[initial_108] = "1" or "2"').should == {:rule => "A or B", :components => ['[initial_108] = "1"', '[initial_108] = "2"']}
    # multiple 'or' on the right
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[initial_52] = "1" or "2" or "3"').should == {:rule => "A or B or C", :components => ['[initial_52] = "1"', '[initial_52] = "2"', '[initial_52] = "3"']}
    # commas on the right
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[initial_189] = "1, 2, 3"').should == {:rule => "(A and B and C)", :components => ['[initial_189] = "1"', '[initial_189] = "2"', '[initial_189] = "3"']}
    # multiple internal parenthesis on the left
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_rule('[initial_119(1)(2)(3)(4)(5)] = "1"').should == {:rule => "(A and B and C and D and E)", :components => ['[initial_119(1)] = "1"', '[initial_119(2)] = "1"', '[initial_119(3)] = "1"', '[initial_119(4)] = "1"', '[initial_119(5)] = "1"']}
  end
  it "should decompose components" do
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_component('[initial_52] = "1"').should == {:question_reference => 'initial_52', :operator => '==', :answer_reference => '1'}
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_component('[initial_119(2)] = "1"').should == {:question_reference => 'initial_119', :operator => '==', :answer_reference => '2'}
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_component('[f1_q15] >= 21').should == {:question_reference => 'f1_q15', :operator => '>=', :integer_value => '21'}
    # basic, blanks
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_component("[f1_q15]=''").should == {:question_reference => 'f1_q15', :operator => '==', :answer_reference => ''}
    # basic, negatives
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_component("[f1_q15]='-2'").should == {:question_reference => 'f1_q15', :operator => '==', :answer_reference => '-2'}
    # internal parenthesis
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_component("[hiprep_heat2(97)] = '1'").should == {:question_reference => 'hiprep_heat2', :operator => '==', :answer_reference => '97'}
    Dependency.new.extend(SurveyorRedcapParserDependencyMethods).decompose_component("[hi_event1_type] <> ''").should == {:question_reference => 'hi_event1_type', :operator => '!=', :answer_reference => ''}

  end
  it "should return a survey object" do
    x = %("Variable / Field Name","Form Name","Field Units","Section Header","Field Type","Field Label","Choices OR Calculations","Field Note","Text Validation Type","Text Validation Min","Text Validation Max",Identifier?,"Branching Logic (Show field only if...)","Required Field?"\nstudy_id,demographics,,,text,"Study ID",,,,,,,,)
    Surveyor::RedcapParser.new.parse(x, "redcaptest").is_a?(Survey).should be_true
  end

end