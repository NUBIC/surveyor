require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe SkipLogicCondition do
  it "should have a list of operators" do
    %w(== != < > <= >=).each do |operator|
      SkipLogicCondition.operators.include?(operator).should be_true
    end
  end

  describe "instance" do
    let!( :skip_logic_condition ) {
      SkipLogicCondition.new(
        :skip_logic => FactoryGirl.create( :skip_logic ),
        :question => FactoryGirl.create( :question ),
        :operator => "==",
        :answer_id => 23,
        :rule_key => "A"
      )
    }

    it "should be valid" do
      skip_logic_condition.should be_valid
    end

    it "should be invalid without a parent skip_logic, question_id" do
      skip_logic_condition.skip_logic_id = nil
      skip_logic_condition.should have(1).errors_on(:skip_logic)
      skip_logic_condition.question_id = nil
      skip_logic_condition.should have(1).errors_on(:question)
    end

    it "should be invalid without an operator" do
      skip_logic_condition.operator = nil
      skip_logic_condition.should have(2).errors_on(:operator)
    end

    it "should be invalid without a rule_key" do
      skip_logic_condition.should be_valid
      skip_logic_condition.rule_key = nil
      skip_logic_condition.should_not be_valid
      skip_logic_condition.should have(1).errors_on(:rule_key)
    end

    it "should have unique rule_key within the context of a skip_logic" do
      skip_logic_condition.should be_valid
      skip_logic = FactoryGirl.create( :skip_logic )
      SkipLogicCondition.create(
        :skip_logic => skip_logic,
        :question => FactoryGirl.create( :question ),
        :operator => "==",
        :answer_id => 14,
        :rule_key => "B"
      ).should be_valid
      skip_logic_condition.rule_key = "B" # rule key uniquness is scoped by skip_logic_id
      skip_logic_condition.skip_logic_id = skip_logic.id
      skip_logic_condition.should_not be_valid
      skip_logic_condition.should have(1).errors_on(:rule_key)
    end

    it "should have an operator in SkipLogicCondition.operators" do
      SkipLogicCondition.operators.each do |o|
        skip_logic_condition.operator = o
        skip_logic_condition.should have(0).errors_on(:operator)
      end
      skip_logic_condition.operator = "#"
      skip_logic_condition.should have(1).error_on(:operator)
    end
    it "should have a properly formed count operator" do
      %w(count>1 count<1 count>=1 count<=1 count==1 count!=1).each do |o|
        skip_logic_condition.operator = o
        skip_logic_condition.should have(0).errors_on(:operator)
      end
      %w(count> count< count>= count<= count== count!=).each do |o|
        skip_logic_condition.operator = o
        skip_logic_condition.should have(1).errors_on(:operator)
      end
      %w(count=1 count><1 count<>1 count!1 count!!1 count=>1 count=<1).each do |o|
        skip_logic_condition.operator = o
        skip_logic_condition.should have(1).errors_on(:operator)
      end
      %w(count= count>< count<> count! count!! count=> count=< count> count< count>= count<= count== count!=).each do |o|
        skip_logic_condition.operator = o
        skip_logic_condition.should have(1).errors_on(:operator)
      end
    end
  end

  it "returns true for != with no responses" do
    question = FactoryGirl.create(:question)
    skip_logic_condition = FactoryGirl.create(:skip_logic_condition, :rule_key => "C", :question => question)
    rs = FactoryGirl.create(:response_set)
    skip_logic_condition.to_hash(rs).should == {:C => false}
  end


  it "should not assume that Response#as is not nil" do
    # q_HEIGHT_FT "Portion of height in whole feet (e.g., 5)",
    # :pick=>:one
    # a :integer
    # a_neg_1 "Refused"
    # a_neg_2 "Don't know"
    # label "Provided value is outside of the suggested range (4 to 7 feet). This value is admissible, but you may wish to verify."
    # skip_logic :rule=>"A or B"
    # condition_A :q_HEIGHT_FT, "<", {:integer_value => "4"}
    # condition_B :q_HEIGHT_FT, ">", {:integer_value => "7"}

    answer = FactoryGirl.create(:answer, :response_class => :integer)
    skip_logic_condition = SkipLogicCondition.new(
      :skip_logic => FactoryGirl.create(:skip_logic),
      :question => answer.question,
      :answer => answer,
      :operator => ">",
      :integer_value => 4,
      :rule_key => "A")

    response = FactoryGirl.create(:response, :answer => answer, :question => answer.question)
    response_set = response.response_set
    response.integer_value.should == nil

    skip_logic_condition.to_hash(response_set).should == {:A => false}
  end

  describe "evaluate '==' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer, :response_class => "answer")
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set.reload
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "D")
      @slc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @slc.to_hash(@rs).should == {:D => true}
      @slc.answer = @b
      @slc.to_hash(@rs).should == {:D => false}
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      update_response(:string_value => "hello123")
      @slc.string_value = "hello123"
      @slc.to_hash(@rs).should == {:D => true}
      update_response(:string_value => "foo_abc")
      @slc.to_hash(@rs).should == {:D => false}
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      update_response(:text_value => "hello this is some text for comparison")
      @slc.text_value = "hello this is some text for comparison"
      @slc.to_hash(@rs).should == {:D => true}
      update_response(:text_value => "Not the same text")
      @slc.to_hash(@rs).should == {:D => false}
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      update_response(:integer_value => 10045)
      @slc.integer_value = 10045
      @slc.to_hash(@rs).should == {:D => true}
      update_response(:integer_value => 421)
      @slc.to_hash(@rs).should == {:D => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      update_response(:float_value => 121.1)
      @slc.float_value = 121.1
      @slc.to_hash(@rs).should == {:D => true}
      update_response(:float_value => 130.123)
      @slc.to_hash(@rs).should == {:D => false}
    end
  end

  describe "evaluate '!=' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set.reload
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => "!=", :rule_key => "E")
      @slc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @slc.to_hash(@rs).should == {:E => false}
      @slc.answer_id = @a.id.to_i+1
      @slc.to_hash(@rs).should == {:E => true}
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      update_response(:string_value => "hello123")
      @slc.string_value = "hello123"
      @slc.to_hash(@rs).should == {:E => false}
      update_response(:string_value => "foo_abc")
      @slc.to_hash(@rs).should == {:E => true}
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      update_response(:text_value => "hello this is some text for comparison")
      @slc.text_value = "hello this is some text for comparison"
      @slc.to_hash(@rs).should == {:E => false}
      update_response(:text_value => "Not the same text")
      @slc.to_hash(@rs).should == {:E => true}
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      update_response(:integer_value => 10045)
      @slc.integer_value = 10045
      @slc.to_hash(@rs).should == {:E => false}
      update_response(:integer_value => 421)
      @slc.to_hash(@rs).should == {:E => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      update_response(:float_value => 121.1)
      @slc.float_value = 121.1
      @slc.to_hash(@rs).should == {:E => false}
      update_response(:float_value => 130.123)
      @slc.to_hash(@rs).should == {:E => true}
    end
  end

  describe "evaluate the '<' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => "<", :rule_key => "F")
      @slc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      update_response(:integer_value => 50)
      @slc.integer_value = 100
      @slc.to_hash(@rs).should == {:F => true}
      update_response(:integer_value => 421)
      @slc.to_hash(@rs).should == {:F => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      update_response(:float_value => 5.1)
      @slc.float_value = 121.1
      @slc.to_hash(@rs).should == {:F => true}
      update_response(:float_value => 130.123)
      @slc.to_hash(@rs).should == {:F => false}
    end
  end

  describe "evaluate the '<=' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => "<=", :rule_key => "G")
      @slc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      update_response(:integer_value => 50)
      @slc.integer_value = 100
      @slc.to_hash(@rs).should == {:G => true}
      update_response(:integer_value => 100)
      @slc.to_hash(@rs).should == {:G => true}
      update_response(:integer_value => 421)
      @slc.to_hash(@rs).should == {:G => false}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      update_response(:float_value => 5.1)
      @slc.float_value = 121.1
      @slc.to_hash(@rs).should == {:G => true}
      update_response(:float_value => 121.1)
      @slc.to_hash(@rs).should == {:G => true}
      update_response(:float_value => 130.123)
      @slc.to_hash(@rs).should == {:G => false}
    end

  end

  describe "evaluate the '>' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => ">", :rule_key => "H")
      @slc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      update_response(:integer_value => 50)
      @slc.integer_value = 100
      @slc.to_hash(@rs).should == {:H => false}
      update_response(:integer_value => 421)
      @slc.to_hash(@rs).should == {:H => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      update_response(:float_value => 5.1)
      @slc.float_value = 121.1
      @slc.to_hash(@rs).should == {:H => false}
      update_response(:float_value => 130.123)
      @slc.to_hash(@rs).should == {:H => true}
    end
  end

  describe "evaluate the '>=' operator" do
    before(:each) do
      @a = FactoryGirl.create(:answer)
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => ">=", :rule_key => "I")
      @slc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      update_response(:integer_value => 50)
      @slc.integer_value = 100
      @slc.to_hash(@rs).should == {:I => false}
      update_response(:integer_value => 100)
      @slc.to_hash(@rs).should == {:I => true}
      update_response(:integer_value => 421)
      @slc.to_hash(@rs).should == {:I => true}
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      update_response(:float_value => 5.1)
      @slc.float_value = 121.1
      @slc.to_hash(@rs).should == {:I => false}
      update_response(:float_value => 121.1)
      @slc.to_hash(@rs).should == {:I => true}
      update_response(:float_value => 130.123)
      @slc.to_hash(@rs).should == {:I => true}
    end
  end

  describe "evaluating with response_class string" do
    it "should compare answer ids when the skip logic condition string_value is nil" do
      @a = FactoryGirl.create(:answer, :response_class => "string")
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a, :string_value => "")
      @rs = @r.response_set.reload
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "J")
      @slc.to_hash(@rs).should == {:J => true}
    end

    it "should compare strings when the skip logic condition string_value is not nil, even if it is blank", focus: true do
      @a = FactoryGirl.create(:answer, :response_class => "string")
      @b = FactoryGirl.create(:answer, :question => @a.question)
      @r = FactoryGirl.create(:response, :question => @a.question, :answer => @a, :string_value => "foo")
      @rs = @r.response_set.reload
      @slc = FactoryGirl.create(:skip_logic_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "K", :string_value => "foo")
      @slc.to_hash(@rs).should == {:K => true}

      update_response(:string_value => "")
      @slc.string_value = ""
      @slc.to_hash(@rs).should == {:K => true}
    end
  end

  describe "evaluate 'count' operator" do
    before(:each) do
      @q = FactoryGirl.create(:question)
      @slc = SkipLogicCondition.new(:operator => "count>2", :rule_key => "M", :question => @q)
      @as = []
      3.times do
        @as << FactoryGirl.create(:answer, :question => @q, :response_class => "answer")
      end
      @rs = FactoryGirl.create(:response_set)
      @as.slice(0,2).each do |a|
        FactoryGirl.create(:response, :question => @q, :answer => a, :response_set => @rs)
      end
      @rs.save
      @rs.reload
    end

    it "with operator with >" do
      @slc.to_hash(@rs).should == {:M => false}
      FactoryGirl.create(:response, :question => @q, :answer => @as.last, :response_set => @rs)
      @rs.reload.responses.count.should == 3
      @slc.to_hash(@rs.reload).should == {:M => true}
    end

    it "with operator with <" do
      @slc.operator = "count<2"
      @slc.to_hash(@rs).should == {:M => false}
      @slc.operator = "count<3"
      @slc.to_hash(@rs).should == {:M => true}
    end

    it "with operator with <=" do
      @slc.operator = "count<=1"
      @slc.to_hash(@rs).should == {:M => false}
      @slc.operator = "count<=2"
      @slc.to_hash(@rs).should == {:M => true}
      @slc.operator = "count<=3"
      @slc.to_hash(@rs).should == {:M => true}
    end

    it "with operator with >=" do
      @slc.operator = "count>=1"
      @slc.to_hash(@rs).should == {:M => true}
      @slc.operator = "count>=2"
      @slc.to_hash(@rs).should == {:M => true}
      @slc.operator = "count>=3"
      @slc.to_hash(@rs).should == {:M => false}
    end

    it "with operator with !=" do
      @slc.operator = "count!=1"
      @slc.to_hash(@rs).should == {:M => true}
      @slc.operator = "count!=2"
      @slc.to_hash(@rs).should == {:M => false}
      @slc.operator = "count!=3"
      @slc.to_hash(@rs).should == {:M => true}
    end
  end

  def update_response(values)
    @r.update_attributes(values)
    @rs.reload
  end

end
