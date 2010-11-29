require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::RedcapParser do
  before(:each) do
    # @parser = Surveyor::Parser.new
  end
  it "should decompose dependency rules" do
    # basic
    Dependency.decompose_rule('[f1_q12]="1"').should == {:rule => "A", :components => ['[f1_q12]="1"']}
    # spacing
    Dependency.decompose_rule('[f1_q9] = "1"').should == {:rule => "A", :components => ['[f1_q9] = "1"']}
    # internal parenthesis
    Dependency.decompose_rule('[f1_q10(4)]="1"').should == {:rule => "A", :components => ['[f1_q10(4)]="1"']}
    # internal and external parenthesis
    Dependency.decompose_rule('([f1_q7(11)] = "1" or [initial_52] = "1") and [pre_q76]="2"').should == {:rule => "(A or B) and C", :components => ['[f1_q7(11)] = "1"', '[initial_52] = "1"', '[pre_q76]="2"']}
    # internal 'or', on the right of the operator
    Dependency.decompose_rule('[initial_108] = "1" or "2"').should == {:rule => "A or B", :components => ['[initial_108] = "1"', '[initial_108] = "2"']}
    
    # Dependency.decompose_rule().should == {:rule => "A", :components => []}
    # Dependency.decompose_rule().should == {:rule => "A", :components => []}
    # Dependency.decompose_rule().should == {:rule => "A", :components => []}
    # Dependency.decompose_rule().should == {:rule => "A", :components => []}
    # Dependency.decompose_rule().should == {:rule => "A", :components => []}
    # Dependency.decompose_rule().should == {:rule => "A", :components => []}
    # Dependency.decompose_rule().should == {:rule => "A", :components => []}
    # Dependency.decompose_rule('[initial_189] = "1, 2, 3"').should == {:rule => "A and B and C", :components => ['[initial_189] = "1',' 2',' 3"']}
    
    
    '[initial_119(1)(2)(3)(4)(6)] = "1"'
    
    '[initial_189] = "1, 2, 3"'
    '[initial_108] = "1" or "2"'
    '[initial_52] = "1" or "2" or "3"'
    
    '[pre_q88]="1" and [pre_q90]="1"'
    '[second_q111]="1" or [second_q111]="3"'
    '[second_q100]="1" or [second_q100]="3" and [second_q101]="1"'
    '[second_q4]="1" and [second_q11]="1" or [second_q11]="98"'
    '[pre_q74]="1" or [pre_q74]="2" or [pre_q74]="4" or [pre_q74]="5"'
    '[f1_q15] >= 21 and [f1_q28] ="1"'
    '([pre_q74]="1" or [pre_q74]="2" or [pre_q74]="4" or [pre_q74]="5") and [pre_q76]="2"'
  end

end