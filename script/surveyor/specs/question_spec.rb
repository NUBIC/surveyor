require File.dirname(__FILE__) + '/../question'

describe Question, " when first created" do
  TEST_ID = 1
  TEST_CONTEXT_ID = "B3"
  TEST_SECTION_ID = 2
  TEST_TEXT = "In the past 12 months how many times have you been to a doctor?"
  TEST_HELP_TEXT = "Please give a rough estimate"
  TEST_OPTIONS = {:help_text => TEST_HELP_TEXT }
  TEST_CODE = "many_times_you_been_doctor"

  before do    
    @ques = Question.new(TEST_ID, TEST_SECTION_ID, TEST_CONTEXT_ID, TEST_TEXT, TEST_OPTIONS)
  end
  
  it "should set initialization parameters properly" do
    @ques.id.should == TEST_ID
    @ques.context_id.should == TEST_CONTEXT_ID
    @ques.section_id.should == TEST_SECTION_ID
    @ques.code.should == TEST_CODE
    @ques.options[:help_text].should == TEST_HELP_TEXT
    
    #Checking the defaults
    @ques.options[:has_omit?].should == true
    @ques.options[:has_other?].should == false
    @ques.options[:answer_format].should == :medium_text
  end

  it "should output current state to yml" do
     @ques.should.respond_to?(:to_yml)
  end
  
  it "should create a normalized code from the answer text" do
    # The question object should take the title of the text and convert
    # it to a code that is more appropirate for a database entry
    
    # Taking a few questions from the survey for testing
    str = []
    str[0] = "How long has it been since you last visited a doctor for a routine checkup (routine being not for a particular reason)?"
    str[1] = "Do you take medications as directed?"
    str[2] = "Do you every leak urine (or) water when you didn't want to?" #checking for () and ' removal
    str[3] = "Do your biological family members (not adopted) have a \"history\" of any of the following?"
    str[4] = "Your health:"
    str[5] = "In general, you would say your health is:"
    
    # What the results should look like
    r_str = []
    r_str[0] = "visited_doctor_for_routine_checkup"
    r_str[1] = "you_take_medications_as_directed"
    r_str[2] = "urine_water_you_didnt_want"
    r_str[3] = "family_members_history_any_following"
    r_str[4] = "your_health"
    r_str[5] = "you_would_say_your_health"
    
    count = 0 
    str.each do |s|
       
       code = Question.to_normalized_code(s)  
       code.should eql(r_str[count])
       count += 1
      
    end
    
  end
  
  it "should create a normalized code automatically when initalized" do
    @ques.code.should eql(TEST_CODE)
  end
  
  it "should update the normalized code if the title is changed" do
    @ques.code.should eql(TEST_CODE)
    @ques.text = "Sometimes or All the time?"
    @ques.code.should eql("sometimes_all_time")
  end

end

describe Question, " when it contains data" do
  
  before do # Mocking up some answers
    @question = Question.new(1,TEST_SECTION_ID,TEST_CONTEXT_ID,TEST_TEXT,TEST_OPTIONS)
    ma1 = mock("answer")
    ma1.stub!(:context_id).and_return("1")
    @question.add_answer(ma1)
    
    ma2 = mock("answer")
    ma2.stub!(:context_id).and_return("2")
    @question.add_answer(ma2)
    
    ma3 = mock("answer")
    ma3.stub!(:context_id).and_return("3")
    @question.add_answer(ma3)
    
  end
  
  it "should have added the test answers correctly" do
    @question.answers.length.should eql(3)
  end
  
  it "should have a question text" do
    @question.text.should eql(TEST_TEXT)
  end
  
  it "should find an answer by context_id" do
    pending # yoon: commented out during dsl refactoring
    a_to_find = @question.find_answer_by_context_id("2")
    a_to_find.should_not eql(nil)
    a_to_find.context_id.should eql("2")
  end
  
end
