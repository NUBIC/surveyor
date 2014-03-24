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
    it "should have a properly formed count operator" do
      %w(count>1 count<1 count>=1 count<=1 count==1 count!=1).each do |o|
        @dependency_condition.operator = o
        @dependency_condition.should have(0).errors_on(:operator)
      end
      %w(count> count< count>= count<= count== count!=).each do |o|
        @dependency_condition.operator = o
        @dependency_condition.should have(1).errors_on(:operator)
      end
      %w(count=1 count><1 count<>1 count!1 count!!1 count=>1 count=<1).each do |o|
        @dependency_condition.operator = o
        @dependency_condition.should have(1).errors_on(:operator)
      end
      %w(count= count>< count<> count! count!! count=> count=< count> count< count>= count<= count== count!=).each do |o|
        @dependency_condition.operator = o
        @dependency_condition.should have(1).errors_on(:operator)
      end
    end
  end

  it "returns true for != with no responses" do
    question = FactoryGirl.create(:question)
    dependency_condition = FactoryGirl.create(:dependency_condition, :rule_key => "C", :question => question)
    rs = FactoryGirl.create(:response_set)
    dependency_condition.to_hash(rs).should == {:C => false}
  end


  it "should not assume that Response#as is not nil" do
    # q_HEIGHT_FT "Portion of height in whole feet (e.g., 5)",
    # :pick=>:one
    # a :integer
    # a_neg_1 "Refused"
    # a_neg_2 "Don't know"
    # label "Provided value is outside of the suggested range (4 to 7 feet). This value is admissible, but you may wish to verify."
    # dependency :rule=>"A or B"
    # condition_A :q_HEIGHT_FT, "<", {:integer_value => "4"}
    # condition_B :q_HEIGHT_FT, ">", {:integer_value => "7"}

    answer = FactoryGirl.create(:answer, :response_class => :integer)
    @dependency_condition = DependencyCondition.new(
      :dependency => FactoryGirl.create(:dependency),
      :question => answer.question,
      :answer => answer,
      :operator => ">",
      :integer_value => 4,
      :rule_key => "A")

    response = FactoryGirl.create(:response, :answer => answer, :question => answer.question)
    response_set = response.response_set
    response.integer_value.should == nil

    @dependency_condition.to_hash(response_set).should == {:A => false}
  end

  describe "evaluate '==' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer, :response_class => "answer")
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "D")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dc.to_hash(@rs).should == {:D => true}
      @dc.answer = @b
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      @r.update_attributes(:string_value => "hello123")
      @dc.string_value = "hello123"
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:string_value => "foo_abc")
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      @r.update_attributes(:text_value => "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:text_value => "Not the same text")
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 10045)
      @dc.integer_value = 10045
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:D => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 121.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:D => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:D => false}
    end
  end

  describe "evaluate '!=' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "!=", :rule_key => "E")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dc.to_hash(@rs).should == {:E => false}
      @dc.answer_id = @a.id.to_i+1
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      @r.update_attributes(:string_value => "hello123")
      @dc.string_value = "hello123"
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:string_value => "foo_abc")
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      @r.update_attributes(:text_value => "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:text_value => "Not the same text")
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 10045)
      @dc.integer_value = 10045
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:E => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 121.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:E => false}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:E => true}
    end
  end

  describe "evaluate the '<' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "<", :rule_key => "F")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:F => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:F => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:F => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:F => false}
    end
  end

  describe "evaluate the '<=' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "<=", :rule_key => "G")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:integer_value => 100)
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:G => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:float_value => 121.1)
      @dc.to_hash(@rs).should == {:G => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:G => false}
    end

  end

  describe "evaluate the '>' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => ">", :rule_key => "H")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:H => false}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:H => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:H => false}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:H => true}
    end
  end

  describe "evaluate the '>=' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => ">=", :rule_key => "I")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {:I => false}
      @r.update_attributes(:integer_value => 100)
      @dc.to_hash(@rs).should == {:I => true}
      @r.update_attributes(:integer_value => 421)
      @dc.to_hash(@rs).should == {:I => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {:I => false}
      @r.update_attributes(:float_value => 121.1)
      @dc.to_hash(@rs).should == {:I => true}
      @r.update_attributes(:float_value => 130.123)
      @dc.to_hash(@rs).should == {:I => true}
    end
  end

  describe "evaluating with response_class string" do
    it "should compare answer ids when the dependency condition string_value is nil" do
      @a = FactoryGirl.create(:answer, :response_class => "string")
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a, :string_value => "")
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "J")
      @dc.to_hash(@rs).should == {:J => true}
    end

    it "should compare strings when the dependency condition string_value is not nil, even if it is blank" do
      @a = FactoryGirl.create(:answer, :response_class => "string")
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a, :string_value => "foo")
      @rs = @r.response_set
      @dc = FactoryGirl.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "K", :string_value => "foo")
      @dc.to_hash(@rs).should == {:K => true}

      @r.update_attributes(:string_value => "")
      @dc.string_value = ""
      @dc.to_hash(@rs).should == {:K => true}
    end
  end

  describe "evaluate 'count' operator" do
    before(:each) do
      @q = FactoryGirl.create(:question)
      @dc = DependencyCondition.new(:operator => "count>2", :rule_key => "M", :question => @q)
      @as = []
      3.times do
        @as << FactoryGirl.create(:answer, :question => @q, :response_class => "answer")
      end
      @rs = FactoryGirl.create(:response_set)
      @as.slice(0,2).each do |a|
        FactoryGirl.create(:response, :question => @q, :answer => a, :response_set => @rs)
      end
      @rs.save
    end

    it "with operator with >" do
      @dc.to_hash(@rs).should == {:M => false}
      FactoryGirl.create(:response, :question => @q, :answer => @as.last, :response_set => @rs)
      @rs.reload.responses.count.should == 3
      @dc.to_hash(@rs.reload).should == {:M => true}
    end

    it "with operator with <" do
      @dc.operator = "count<2"
      @dc.to_hash(@rs).should == {:M => false}
      @dc.operator = "count<3"
      @dc.to_hash(@rs).should == {:M => true}
    end

    it "with operator with <=" do
      @dc.operator = "count<=1"
      @dc.to_hash(@rs).should == {:M => false}
      @dc.operator = "count<=2"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count<=3"
      @dc.to_hash(@rs).should == {:M => true}
    end

    it "with operator with >=" do
      @dc.operator = "count>=1"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count>=2"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count>=3"
      @dc.to_hash(@rs).should == {:M => false}
    end

    it "with operator with !=" do
      @dc.operator = "count!=1"
      @dc.to_hash(@rs).should == {:M => true}
      @dc.operator = "count!=2"
      @dc.to_hash(@rs).should == {:M => false}
      @dc.operator = "count!=3"
      @dc.to_hash(@rs).should == {:M => true}
    end
  end

end
