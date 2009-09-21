require File.dirname(__FILE__) + '/../question_dependency'

describe QuestionDependency, " when first created" do

  ID = 1
  QUESTION_ID = 2
  DEPENDENT_QUESTION_ID = 3
  DEPENDENT_GROUP_ID = nil
  DEPENDENCY_TYPE_1 = {:dependency_type => :response_count, :conditional => :one_or_more }
  DEPENDENCY_TYPE_2 = {:dependency_type => :response_answer, :conditional => :selected, :answer_id => 1}
  DEPENDENCY_TYPE_3 = {:dependency_type => :response_value, :condition => :not_zero}

  before do    
    @dependent_1 = QuestionDependency.new(ID, QUESTION_ID, DEPENDENT_QUESTION_ID, DEPENDENT_GROUP_ID, DEPENDENCY_TYPE_1)
    @dependent_2 = QuestionDependency.new(ID, QUESTION_ID, DEPENDENT_QUESTION_ID, DEPENDENT_GROUP_ID, DEPENDENCY_TYPE_2)
    @dependent_3 = QuestionDependency.new(ID, QUESTION_ID, DEPENDENT_QUESTION_ID, DEPENDENT_GROUP_ID, DEPENDENCY_TYPE_3)
    
  end
  
  it "should set initialization paramerters properly" do
    # Checking both type1 and type2 dependencies
    @dependent_1.id.should == ID
    @dependent_1.question_id.should == QUESTION_ID
    @dependent_1.dependent_question_id.should == DEPENDENT_QUESTION_ID
    @dependent_1.dependency_type.should == DEPENDENCY_TYPE_1[:dependency_type]
    @dependent_1.conditional.should == DEPENDENCY_TYPE_1[:conditional]
    
    @dependent_2.id.should == ID
    @dependent_2.question_id.should == QUESTION_ID
    @dependent_2.dependent_question_id.should == DEPENDENT_QUESTION_ID
    @dependent_2.dependency_type.should == DEPENDENCY_TYPE_2[:dependency_type]
    @dependent_2.conditional.should == DEPENDENCY_TYPE_2[:conditional]
    @dependent_2.answer_id.should == DEPENDENCY_TYPE_2[:answer_id]
    
    @dependent_3.id.should == ID
    @dependent_3.question_id.should == QUESTION_ID
    @dependent_3.dependent_question_id.should == DEPENDENT_QUESTION_ID
    @dependent_3.dependency_type.should == DEPENDENCY_TYPE_3[:dependency_type]
    @dependent_3.conditional.should == DEPENDENCY_TYPE_3[:conditional]
  end
  
  it "should output current state to yml" do
     @ans.should.respond_to?(:to_yml)
  end

end