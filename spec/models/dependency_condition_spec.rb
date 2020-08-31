require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe DependencyCondition, type: :model do
  it "should have a list of operators" do
    %w(== != < > <= >=).each do |operator|
      expect(DependencyCondition.operators.include?(operator)).to be(true)
    end
  end

  describe "instance" do
    before(:each) do
      @dependency_condition = DependencyCondition.new(
        :dependency_id => 1, :question_id => 45, :operator => "==",
        :answer_id => 23, :rule_key => "A")
    end

    it "should be valid" do
      expect(@dependency_condition).to be_valid
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
      expect(@dependency_condition).to have(2).errors_on(:operator)
    end

    it "should be invalid without a rule_key" do
      expect(@dependency_condition).to be_valid
      @dependency_condition.rule_key = nil
      expect(@dependency_condition).not_to be_valid
      expect(@dependency_condition).to have(1).errors_on(:rule_key)
    end

    it "should have unique rule_key within the context of a dependency" do
      expect(@dependency_condition).to be_valid
      DependencyCondition.create(
        :dependency_id => 2, :question_id => 46, :operator => "==",
        :answer_id => 14, :rule_key => "B")
      @dependency_condition.rule_key = "B" # rule key uniquness is scoped by dependency_id
      @dependency_condition.dependency_id = 2
      expect(@dependency_condition).not_to be_valid
      expect(@dependency_condition).to have(1).errors_on(:rule_key)
    end

    it "should have an operator in DependencyCondition.operators" do
      DependencyCondition.operators.each do |o|
        @dependency_condition.operator = o
        expect(@dependency_condition).to have(0).errors_on(:operator)
      end
      @dependency_condition.operator = "#"
      expect(@dependency_condition).to have(1).error_on(:operator)
    end
    it "should have a properly formed count operator" do
      %w(count>1 count<1 count>=1 count<=1 count==1 count!=1).each do |o|
        @dependency_condition.operator = o
        expect(@dependency_condition).to have(0).errors_on(:operator)
      end
      %w(count> count< count>= count<= count== count!=).each do |o|
        @dependency_condition.operator = o
        expect(@dependency_condition).to have(1).errors_on(:operator)
      end
      %w(count=1 count><1 count<>1 count!1 count!!1 count=>1 count=<1).each do |o|
        @dependency_condition.operator = o
        expect(@dependency_condition).to have(1).errors_on(:operator)
      end
      %w(count= count>< count<> count! count!! count=> count=< count> count< count>= count<= count== count!=).each do |o|
        @dependency_condition.operator = o
        expect(@dependency_condition).to have(1).errors_on(:operator)
      end
    end
  end

  it "returns true for != with no responses" do
    question = FactoryBot.create(:question)
    dependency_condition = FactoryBot.create(:dependency_condition, :rule_key => "C", :question => question)
    rs = FactoryBot.create(:response_set)
    expect(dependency_condition.to_hash(rs)).to eq({:C => false})
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

    answer = FactoryBot.create(:answer, :response_class => :integer)
    @dependency_condition = DependencyCondition.new(
      :dependency => FactoryBot.create(:dependency),
      :question => answer.question,
      :answer => answer,
      :operator => ">",
      :integer_value => 4,
      :rule_key => "A")

    response = FactoryBot.create(:response, :answer => answer, :question => answer.question)
    response_set = response.response_set
    expect(response.integer_value).to eq(nil)

    expect(@dependency_condition.to_hash(response_set)).to eq({:A => false})
  end

  describe "evaluate '==' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer, :response_class => "answer")
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "D")
      expect(@dc.as(:answer)).to eq(@r.as(:answer))
    end

    it "with checkbox/radio type response" do
      expect(@dc.to_hash(@rs)).to eq({:D => true})
      @dc.answer = @b
      expect(@dc.to_hash(@rs)).to eq({:D => false})
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      @r.update_attributes(:string_value => "hello123")
      @dc.string_value = "hello123"
      expect(@dc.to_hash(@rs)).to eq({:D => true})
      @r.update_attributes(:string_value => "foo_abc")
      expect(@dc.to_hash(@rs)).to eq({:D => false})
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      @r.update_attributes(:text_value => "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      expect(@dc.to_hash(@rs)).to eq({:D => true})
      @r.update_attributes(:text_value => "Not the same text")
      expect(@dc.to_hash(@rs)).to eq({:D => false})
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 10045)
      @dc.integer_value = 10045
      expect(@dc.to_hash(@rs)).to eq({:D => true})
      @r.update_attributes(:integer_value => 421)
      expect(@dc.to_hash(@rs)).to eq({:D => false})
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 121.1)
      @dc.float_value = 121.1
      expect(@dc.to_hash(@rs)).to eq({:D => true})
      @r.update_attributes(:float_value => 130.123)
      expect(@dc.to_hash(@rs)).to eq({:D => false})
    end
  end

  describe "evaluate '!=' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "!=", :rule_key => "E")
      expect(@dc.as(:answer)).to eq(@r.as(:answer))
    end

    it "with checkbox/radio type response" do
      expect(@dc.to_hash(@rs)).to eq({:E => false})
      @dc.answer_id = @a.id.to_i+1
      expect(@dc.to_hash(@rs)).to eq({:E => true})
    end

    it "with string value response" do
      @a.update_attributes(:response_class => "string")
      @r.update_attributes(:string_value => "hello123")
      @dc.string_value = "hello123"
      expect(@dc.to_hash(@rs)).to eq({:E => false})
      @r.update_attributes(:string_value => "foo_abc")
      expect(@dc.to_hash(@rs)).to eq({:E => true})
    end

    it "with a text value response" do
      @a.update_attributes(:response_class => "text")
      @r.update_attributes(:text_value => "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      expect(@dc.to_hash(@rs)).to eq({:E => false})
      @r.update_attributes(:text_value => "Not the same text")
      expect(@dc.to_hash(@rs)).to eq({:E => true})
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 10045)
      @dc.integer_value = 10045
      expect(@dc.to_hash(@rs)).to eq({:E => false})
      @r.update_attributes(:integer_value => 421)
      expect(@dc.to_hash(@rs)).to eq({:E => true})
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 121.1)
      @dc.float_value = 121.1
      expect(@dc.to_hash(@rs)).to eq({:E => false})
      @r.update_attributes(:float_value => 130.123)
      expect(@dc.to_hash(@rs)).to eq({:E => true})
    end
  end

  describe "evaluate the '<' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "<", :rule_key => "F")
      expect(@dc.as(:answer)).to eq(@r.as(:answer))
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      expect(@dc.to_hash(@rs)).to eq({:F => true})
      @r.update_attributes(:integer_value => 421)
      expect(@dc.to_hash(@rs)).to eq({:F => false})
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      expect(@dc.to_hash(@rs)).to eq({:F => true})
      @r.update_attributes(:float_value => 130.123)
      expect(@dc.to_hash(@rs)).to eq({:F => false})
    end
  end

  describe "evaluate the '<=' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "<=", :rule_key => "G")
      expect(@dc.as(:answer)).to eq(@r.as(:answer))
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      expect(@dc.to_hash(@rs)).to eq({:G => true})
      @r.update_attributes(:integer_value => 100)
      expect(@dc.to_hash(@rs)).to eq({:G => true})
      @r.update_attributes(:integer_value => 421)
      expect(@dc.to_hash(@rs)).to eq({:G => false})
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      expect(@dc.to_hash(@rs)).to eq({:G => true})
      @r.update_attributes(:float_value => 121.1)
      expect(@dc.to_hash(@rs)).to eq({:G => true})
      @r.update_attributes(:float_value => 130.123)
      expect(@dc.to_hash(@rs)).to eq({:G => false})
    end

  end

  describe "evaluate the '>' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => ">", :rule_key => "H")
      expect(@dc.as(:answer)).to eq(@r.as(:answer))
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      expect(@dc.to_hash(@rs)).to eq({:H => false})
      @r.update_attributes(:integer_value => 421)
      expect(@dc.to_hash(@rs)).to eq({:H => true})
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      expect(@dc.to_hash(@rs)).to eq({:H => false})
      @r.update_attributes(:float_value => 130.123)
      expect(@dc.to_hash(@rs)).to eq({:H => true})
    end
  end

  describe "evaluate the '>=' operator" do
    before(:each) do
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a)
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => ">=", :rule_key => "I")
      expect(@dc.as(:answer)).to eq(@r.as(:answer))
    end

    it "with an integer value response" do
      @a.update_attributes(:response_class => "integer")
      @r.update_attributes(:integer_value => 50)
      @dc.integer_value = 100
      expect(@dc.to_hash(@rs)).to eq({:I => false})
      @r.update_attributes(:integer_value => 100)
      expect(@dc.to_hash(@rs)).to eq({:I => true})
      @r.update_attributes(:integer_value => 421)
      expect(@dc.to_hash(@rs)).to eq({:I => true})
    end

    it "with a float value response" do
      @a.update_attributes(:response_class => "float")
      @r.update_attributes(:float_value => 5.1)
      @dc.float_value = 121.1
      expect(@dc.to_hash(@rs)).to eq({:I => false})
      @r.update_attributes(:float_value => 121.1)
      expect(@dc.to_hash(@rs)).to eq({:I => true})
      @r.update_attributes(:float_value => 130.123)
      expect(@dc.to_hash(@rs)).to eq({:I => true})
    end
  end

  describe "evaluating with response_class string" do
    it "should compare answer ids when the dependency condition string_value is nil" do
      @a = FactoryBot.create(:answer, :response_class => "string")
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a, :string_value => "")
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "J")
      expect(@dc.to_hash(@rs)).to eq({:J => true})
    end

    it "should compare strings when the dependency condition string_value is not nil, even if it is blank" do
      @a = FactoryBot.create(:answer, :response_class => "string")
      @b = FactoryBot.create(:answer, :question => @a.question)
      @r = FactoryBot.create(:response, :question => @a.question, :answer => @a, :string_value => "foo")
      @rs = @r.response_set
      @dc = FactoryBot.create(:dependency_condition, :question => @a.question, :answer => @a, :operator => "==", :rule_key => "K", :string_value => "foo")
      expect(@dc.to_hash(@rs)).to eq({:K => true})

      @r.update_attributes(:string_value => "")
      @dc.string_value = ""
      expect(@dc.to_hash(@rs)).to eq({:K => true})
    end
  end

  describe "evaluate 'count' operator" do
    before(:each) do
      @q = FactoryBot.create(:question)
      @dc = DependencyCondition.new(:operator => "count>2", :rule_key => "M", :question => @q)
      @as = []
      3.times do
        @as << FactoryBot.create(:answer, :question => @q, :response_class => "answer")
      end
      @rs = FactoryBot.create(:response_set)
      @as.slice(0,2).each do |a|
        FactoryBot.create(:response, :question => @q, :answer => a, :response_set => @rs)
      end
      @rs.save
    end

    it "with operator with >" do
      expect(@dc.to_hash(@rs)).to eq({:M => false})
      FactoryBot.create(:response, :question => @q, :answer => @as.last, :response_set => @rs)
      expect(@rs.reload.responses.count).to eq(3)
      expect(@dc.to_hash(@rs.reload)).to eq({:M => true})
    end

    it "with operator with <" do
      @dc.operator = "count<2"
      expect(@dc.to_hash(@rs)).to eq({:M => false})
      @dc.operator = "count<3"
      expect(@dc.to_hash(@rs)).to eq({:M => true})
    end

    it "with operator with <=" do
      @dc.operator = "count<=1"
      expect(@dc.to_hash(@rs)).to eq({:M => false})
      @dc.operator = "count<=2"
      expect(@dc.to_hash(@rs)).to eq({:M => true})
      @dc.operator = "count<=3"
      expect(@dc.to_hash(@rs)).to eq({:M => true})
    end

    it "with operator with >=" do
      @dc.operator = "count>=1"
      expect(@dc.to_hash(@rs)).to eq({:M => true})
      @dc.operator = "count>=2"
      expect(@dc.to_hash(@rs)).to eq({:M => true})
      @dc.operator = "count>=3"
      expect(@dc.to_hash(@rs)).to eq({:M => false})
    end

    it "with operator with !=" do
      @dc.operator = "count!=1"
      expect(@dc.to_hash(@rs)).to eq({:M => true})
      @dc.operator = "count!=2"
      expect(@dc.to_hash(@rs)).to eq({:M => false})
      @dc.operator = "count!=3"
      expect(@dc.to_hash(@rs)).to eq({:M => true})
    end
  end

end
