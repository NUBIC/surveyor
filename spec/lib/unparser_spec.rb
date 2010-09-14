require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::Unparser do
  before(:each) do
    @survey = Survey.new(:title => "Simple survey", :description => "very simple")
    @section = @survey.sections.build(:title => "Simple section")
  end
  
  it "should unparse a basic survey, section, and question" do
    q1 = @section.questions.build(:text => "What is your favorite color?", :reference_identifier => 1, :pick => :one)
    a11 = q1.answers.build(:text => "red", :response_class => "answer", :reference_identifier => 1, :question => q1)
    a12 = q1.answers.build(:text => "green", :response_class => "answer", :reference_identifier => 2, :question => q1)
    a13 = q1.answers.build(:text => "blue", :response_class => "answer", :reference_identifier => 3, :question => q1)
    a14 = q1.answers.build(:text => "Other", :response_class => "string", :reference_identifier => 4, :question => q1)
    a15 = q1.answers.build(:text => "Omit", :reference_identifier => 5, :question => q1, :is_exclusive => true)
    q2 = @section.questions.build(:text => "What is your name?", :reference_identifier => 2, :pick => :none)
    a21 = q2.answers.build(:response_class => "string", :reference_identifier => 1, :question => q2)
    Surveyor::Unparser.unparse(@survey).should ==
<<-dsl
survey "Simple survey", :description=>"very simple" do
  section "Simple section" do

    q_1 "What is your favorite color?", :pick=>"one"
    a_1 "red"
    a_2 "green"
    a_3 "blue"
    a_4 :other, :string
    a_5 :omit

    q_2 "What is your name?"
    a_1 :string
  end
end
dsl
  end
  
  it "should unparse groups" do
    q3 = @section.questions.build(:text => "Happy?")    
    a31 = q3.answers.build(:text => "Yes", :question => q3)
    a32 = q3.answers.build(:text => "Maybe", :question => q3)
    a33 = q3.answers.build(:text => "No", :question => q3)
    
    q4 = @section.questions.build(:text => "Energized?")
    a41 = q4.answers.build(:text => "Yes", :question => q4)
    a42 = q4.answers.build(:text => "Maybe", :question => q4)
    a43 = q4.answers.build(:text => "No", :question => q4)
    
    g1 = q3.build_question_group(:text => "How are you feeling?", :display_type => "grid")
    q4.question_group = g1
    g1.questions = [q3, q4]
    
    q5 = @section.questions.build(:text => "Model")    
    a51 = q5.answers.build(:response_class => "string", :question => q3)
    
    g2 = q5.build_question_group(:text => "Tell us about the cars you own", :display_type => "repeater")
    g2.questions = [q5]
    
    Surveyor::Unparser.unparse(@survey).should ==
<<-dsl
survey "Simple survey", :description=>"very simple" do
  section "Simple section" do

    grid "How are you feeling?" do
      a "Yes"
      a "Maybe"
      a "No"
      q "Happy?"
      q "Energized?"
    end

    repeater "Tell us about the cars you own" do
      q "Model"
      a :string
    end
  end
end
dsl
  end
  
  it "should unparse a basic survey, section, and question" do
    q6 = @section.questions.build(:text => "What... is your name? (e.g. It is 'Arthur', King of the Britons)", :reference_identifier => "montypython3")
    a61 = q6.answers.build(:response_class => "string", :reference_identifier => 1, :question => q6)
    
    q7 = @section.questions.build(:text => "What... is your quest? (e.g. To seek the Holy Grail)", :display_type => "label")
    d1 = q7.build_dependency(:rule => "A", :question => q7)
    dc1 = d1.dependency_conditions.build(:dependency => d1, :question => q6, :answer => a61, :operator => "==", :string_value => "It is 'Arthur', King of the Britons", :rule_key => "A")
    
    q8 = @section.questions.build(:text => "How many pets do you own?")
    a81 = q8.answers.build(:response_class => "integer", :question => q8)
    v1 = a81.validations.build(:rule => "A", :answer => a81)
    vc1 = v1.validation_conditions.build(:operator => ">=", :integer_value => 0, :validation => v1, :rule_key => "A")

    q9 = @section.questions.build(:text => "Pick your favorite date AND time", :custom_renderer => "/partials/custom_question")
    a91 = q9.answers.build(:response_class => "datetime", :question => q9)

    q10 = @section.questions.build(:text => "What time do you usually take a lunch break?", :reference_identifier => "time_lunch")
    a101 = q10.answers.build(:response_class => "time", :reference_identifier => 1, :question => q10)

    Surveyor::Unparser.unparse(@survey).should ==
<<-dsl
survey "Simple survey", :description=>"very simple" do
  section "Simple section" do

    q_montypython3 "What... is your name? (e.g. It is 'Arthur', King of the Britons)"
    a_1 :string

    label "What... is your quest? (e.g. To seek the Holy Grail)"
    dependency :rule=>"A"
    condition_A :q_montypython3, "==", {:string_value=>"It is 'Arthur', King of the Britons", :answer_reference=>"1"}

    q "How many pets do you own?"
    a :integer
    validation :rule=>"A"
    condition_A ">=", :integer_value=>0

    q "Pick your favorite date AND time", :custom_renderer=>"/partials/custom_question"
    a :datetime

    q_time_lunch "What time do you usually take a lunch break?"
    a_1 :time
  end
end
dsl
  end
end

