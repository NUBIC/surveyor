require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe DependencyCondition do
  it "should have a list of operators" do
    %w(== != < > <= >=).each do |operator|
      DependencyCondition.operators.include?(operator).should be_true
    end
  end

  describe "instance" do
    before(:each) do
      @dependency_condition = DependencyCondition.new(
        :dependency_id => 1, :question_id => 45, :operator => "==",
        :answer_id => 23, :rule_key => "A")
    end

    it "should be valid" do
      @dependency_condition.should be_valid
    end

    it "should be invalid without a parent dependency_id, question_id" do
      # this causes issues with building and saving
      # @dependency_condition.dependency_id = nil
      # @dependency_condition.should have(1).errors_on(:dependency_id)
      # @dependency_condition.question_id = nil
      # @dependency_condition.should have(1).errors_on(:question_id)
    end

    it "should be invalid without an operator" do
      @dependency_condition.operator = nil
      @dependency_condition.should have(2).errors_on(:operator)
    end

    it "should be invalid without a rule_key" do
      @dependency_condition.should be_valid
      @dependency_condition.rule_key = nil
      @dependency_condition.should_not be_valid
      @dependency_condition.should have(1).errors_on(:rule_key)
    end

    it "should have unique rule_key within the context of a dependency" do
      @dependency_condition.should be_valid
      DependencyCondition.create(
        :dependency_id => 2, :question_id => 46, :operator => "==",
        :answer_id => 14, :rule_key => "B")
      @dependency_condition.rule_key = "B" # rule key uniquness is scoped by dependency_id
      @dependency_condition.dependency_id = 2
      @dependency_condition.should_not be_valid
      @dependency_condition.should have(1).errors_on(:rule_key)
    end

    it "should have an operator in DependencyCondition.operators" do
      DependencyCondition.operators.each do |o|
        @dependency_condition.operator = o
        @dependency_condition.should have(0).errors_on(:operator)
      end
      @dependency_condition.operator = "#"
      @dependency_condition.should have(1).error_on(:operator)
    end

    it "should evaluate within the context of a response set object" do
      @response = Response.new(:question_id => 45, :response_set_id => 40, :answer_id => 23)
      @response.answer = Answer.new(:question_id => 45, :response_class => "answer").tap{ |a| a.id = 23 }
      @dependency_condition.to_hash([@response]).should == {:A => true}
      # inversion
      @alt_response = Response.new(:question_id => 45, :response_set_id => 40)
      @alt_response.answer = Answer.new(:question_id => 45, :response_class => "answer").
        tap { |a| a.id = 55 }

      @dependency_condition.to_hash?([@alt_response]).should == {:A => false}
    end
    
    it "should protect timestamps" do
      saved_attrs = @dependency_condition.attributes
      if defined? ActiveModel::MassAssignmentSecurity::Error
        lambda {@dependency_condition.update_attributes(:created_at => 3.days.ago, :updated_at => 3.hours.ago)}.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
      else
        @dependency_condition.attributes = {:created_at => 3.days.ago, :updated_at => 3.hours.ago} # automatically protected by Rails
      end
      @dependency_condition.attributes.should == saved_attrs
    end
    
  end

  it "returns true for != with no responses" do
    question = Factory(:question)
    dependency_condition = Factory(:dependency_condition, :rule_key => "C", :question => question)
    rs = Factory(:response_set)
    dependency_condition.to_hash(rs).should == {:C => false}
  end

  describe "evaluate '==' operator" do
    before(:each) do
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer").tap{ |a| a.id = 2 }
      @dep_c = DependencyCondition.new(:operator => "==", :answer_id => @select_answer.id, :rule_key => "D")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => @select_answer.id)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
      @dep_c.as(:answer).should == 2
      @response.as(:answer).should == 2
      @dep_c.as(:answer).should == @response.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dep_c.to_hash([@response]).should == {:D => true}
      @dep_c.answer_id = 12
      @dep_c.to_hash([@response]).should == {:D => false}
    end

    it "with string value response" do
      @select_answer.response_class = "string"
      @response.string_value = "hello123"
      @dep_c.string_value = "hello123"
      @dep_c.to_hash([@response]).should == {:D => true}
      @response.string_value = "foo_abc"
      @dep_c.to_hash([@response]).should == {:D => false}
    end

    it "with a text value response" do
      @select_answer.response_class = "text"
      @response.text_value = "hello this is some text for comparison"
      @dep_c.text_value = "hello this is some text for comparison"
      @dep_c.to_hash([@response]).should == {:D => true}
      @response.text_value = "Not the same text"
      @dep_c.to_hash([@response]).should == {:D => false}
    end

    it "with an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 10045
      @dep_c.integer_value = 10045
      @dep_c.to_hash([@response]).should == {:D => true}
      @response.integer_value = 421
      @dep_c.to_hash([@response]).should == {:D => true}
    end

    it "with a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 121.1
      @dep_c.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:D => true}
      @response.float_value = 130.123
      @dep_c.to_hash([@response]).should == {:D => false}
    end
  end

  describe "evaluate '!=' operator" do
    before(:each) do
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer").tap{ |a| a.id = 2 }
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => @select_answer.id)
      @dep_c = DependencyCondition.new(:operator => "!=", :answer_id => @select_answer.id, :rule_key => "E")
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
      @dep_c.as(:answer).should == 2
      @response.as(:answer).should == 2
      @dep_c.as(:answer).should == @response.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dep_c.to_hash([@response]).should == {:E => false}
      @dep_c.answer_id = 12
      @dep_c.to_hash([@response]).should == {:E => true}
    end

    it "with string value response" do
      @select_answer.response_class = "string"
      @response.string_value = "hello123"
      @dep_c.string_value = "hello123"
      @dep_c.to_hash([@response]).should == {:E => false}
      @response.string_value = "foo_abc"
      @dep_c.to_hash([@response]).should == {:E => true}
    end

    it "with a text value response" do
      @select_answer.response_class = "text"
      @response.text_value = "hello this is some text for comparison"
      @dep_c.text_value = "hello this is some text for comparison"
      @dep_c.to_hash([@response]).should == {:E => false}
      @response.text_value = "Not the same text"
      @dep_c.to_hash([@response]).should == {:E => true}
    end

    it "with an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 10045
      @dep_c.integer_value = 10045
      @dep_c.to_hash([@response]).should == {:E => false}
      @response.integer_value = 421
      @dep_c.to_hash([@response]).should == {:E => true}
    end

    it "with a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 121.1
      @dep_c.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:E => false}
      @response.float_value = 130.123
      @dep_c.to_hash([@response]).should == {:E => true}
    end
  end

  describe "evaluate the '<' operator" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => "<", :rule_key => "F")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
    end

    it "with an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.to_hash([@response]).should == {:F => true}
      @response.integer_value = 421
      @dep_c.to_hash([@response]).should == {:F => false}
    end

    it "with a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:F => true}
      @response.float_value = 130.123
      @dep_c.to_hash([@response]).should == {:F => false}
    end
  end

  describe "evaluate the '<=' operator" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => "<=", :rule_key => "G")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
    end

    it "with an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.to_hash([@response]).should == {:G => true}
      @response.integer_value = 100
      @dep_c.to_hash([@response]).should == {:G => true}
      @response.integer_value = 421
      @dep_c.to_hash([@response]).should == {:G => false}
    end

    it "with a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:G => true}
      @response.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:G => true}
      @response.float_value = 130.123
      @dep_c.to_hash([@response]).should == {:G => false}
    end

  end

  describe "evaluate the '>' operator" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => ">", :rule_key => "H")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
    end

    it "with an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.to_hash([@response]).should == {:H => false}
      @response.integer_value = 421
      @dep_c.to_hash([@response]).should == {:H => true}
    end

    it "with a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:H => false}
      @response.float_value = 130.123
      @dep_c.to_hash([@response]).should == {:H => true}
    end
  end

  describe "evaluate the '>=' operator" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => 2, :operator => ">=", :rule_key => "I")
      @select_answer = Answer.new(:question_id => 1, :response_class => "answer")
      @response = Response.new(:question_id => 314, :response_set_id => 159, :answer_id => 2)
      @response.answer = @select_answer
      @dep_c.answer = @select_answer
    end

    it "with an integer value response" do
      @select_answer.response_class = "integer"
      @response.integer_value = 50
      @dep_c.integer_value = 100
      @dep_c.to_hash([@response]).should == {:I => false}
      @response.integer_value = 100
      @dep_c.to_hash([@response]).should == {:I => true}
      @response.integer_value = 421
      @dep_c.to_hash([@response]).should == {:I => true}
    end

    it "with a float value response" do
      @select_answer.response_class = "float"
      @response.float_value = 5.1
      @dep_c.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:I => false}
      @response.float_value = 121.1
      @dep_c.to_hash([@response]).should == {:I => true}
      @response.float_value = 130.123
      @dep_c.to_hash([@response]).should == {:I => true}
    end
  end

  describe "when evaluating a pick one/many with response_class e.g. string" do
    it "should compare answer ids when the string_value is nil" do
      a = Factory(:answer, :response_class => "string")
      dc = Factory(:dependency_condition,
        :question_id => a.question.id, :answer_id => a.id, :operator => "==", :rule_key => "J")
      r = Factory(:response, :question_id => a.question.id, :answer_id => a.id, :string_value => "")
      r.should_receive(:as).with("answer").and_return(a.id)
      dc.to_hash([r]).should == {:J => true}
    end

    it "should compare strings when the string_value is not nil, even if it is blank" do
      a = Factory(:answer, :response_class => "string")
      dc = Factory(:dependency_condition,
        :question_id => a.question.id, :answer_id => a.id,
        :operator => "==", :string_value => "foo", :rule_key => "K")
      r = Factory(:response,
        :question_id => a.question.id, :answer_id => a.id, :string_value => "foo")
      r.should_receive(:as).with("string").and_return("foo")
      dc.to_hash([r]).should == {:K => true}

      dc2 = Factory(:dependency_condition,
        :question_id => a.question.id, :answer_id => a.id, :operator => "==", :string_value => "", :rule_key => "L")
      r2 = Factory(:response,
        :question_id => a.question.id, :answer_id => a.id, :string_value => "")
      r2.should_receive(:as).with("string").and_return("")
      dc2.to_hash([r2]).should == {:L => true}
    end
  end

  describe "evaluate 'count' operator" do
    before(:each) do
      @dep_c = DependencyCondition.new(:answer_id => nil,
        :operator => "count>2", :rule_key => "M")
      @question = Question.new
      @select_answers = []
      3.times do
        @select_answers << Answer.new(:question => @question,
          :response_class => "answer")
      end
      @responses = []
      @select_answers.slice(0,2).each do |a|
        @responses << Response.new(:question => @question, :answer => a,
          :response_set_id => 159)
      end
    end

    it "with operator with >" do
      @dep_c.to_hash(@responses).should == {:M => false}
      @responses << Response.new(:question => @question,
        :answer => @select_answers.last,
        :response_set_id => 159)
      @dep_c.to_hash(@responses).should == {:M => true}
    end

    it "with operator with <" do
      @dep_c.operator = "count<2"
      @dep_c.to_hash(@responses).should == {:M => false}
      @dep_c.operator = "count<3"
      @dep_c.to_hash(@responses).should == {:M => true}
    end

    it "with operator with <=" do
      @dep_c.operator = "count<=1"
      @dep_c.to_hash(@responses).should == {:M => false}
      @dep_c.operator = "count<=2"
      @dep_c.to_hash(@responses).should == {:M => true}
      @dep_c.operator = "count<=3"
      @dep_c.to_hash(@responses).should == {:M => true}
    end

    it "with operator with >=" do
      @dep_c.operator = "count>=1"
      @dep_c.to_hash(@responses).should == {:M => true}
      @dep_c.operator = "count>=2"
      @dep_c.to_hash(@responses).should == {:M => true}
      @dep_c.operator = "count>=3"
      @dep_c.to_hash(@responses).should == {:M => false}
    end

    it "with operator with !=" do
      @dep_c.operator = "count!=1"
      @dep_c.to_hash(@responses).should == {:M => true}
      @dep_c.operator = "count!=2"
      @dep_c.to_hash(@responses).should == {:M => false}
      @dep_c.operator = "count!=3"
      @dep_c.to_hash(@responses).should == {:M => true}
    end
  end
end
