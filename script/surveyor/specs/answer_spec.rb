require File.dirname(__FILE__) + '/../answer'

describe Answer, " when first created" do

  TEST_ID = 1
  TEST_CONTEXT_ID = "b3a_1"
  TEST_QUESTION_ID = "2"
  TEST_TEXT = "No / Rarely"
  TEST_OPTIONS = {:help_text => "Never or rarely ever"}

  before do    
    @ans = Answer.new(TEST_ID, TEST_QUESTION_ID, TEST_CONTEXT_ID, TEST_TEXT, TEST_OPTIONS)
  end
  
  it "should set inititalized variables to those passed in" do
    @ans.id.should == TEST_ID
    @ans.question_id.should == TEST_QUESTION_ID
    @ans.context_id.should == TEST_CONTEXT_ID
    @ans.text.should == TEST_TEXT
    @ans.help_text.should == TEST_OPTIONS[:help_text]
    end
  
  it "should output current state to yml" do
     @ans.should.respond_to?(:to_yml)
  end
  
  it "should create a normalized code from the answer text" do
    # The answer object should take the title of the text and convert
    # it to a code that is more appropirate for a database entry
    
    # Taking a few answers from the survey for testing
    str = []
    str[0] = "This? is a in - t3rrible-@nswer of! (question) on"
    str[1] = "Private insurance/ HMO/ PPO"
    str[2] = "VA"
    str[3] = "PMS (Premenstrual syndrome)/ PMDD (Premenstrual Dysphoric Disorder)"
    str[4] = "Have never been employed outside the home"
    str[5] = "Professional"
    str[6] = "Not working because of temporary disability, but expect to return to a job"
    
    # What the results should look like
    r_str = []
    r_str[0] = "this_t3rrible_nswer"
    r_str[1] = "private_insurance_hmo_ppo"
    r_str[2] = "va"
    r_str[3] = "pms_pmdd"
    r_str[4] = "never_been_employed_outside_home"
    r_str[5] = "professional"
    r_str[6] = "temporary_disability_expect_return_job"
    
    count = 0 
    str.each do |s|
       
       code = Answer.to_normalized_code(s)  
       code.should eql(r_str[count])
       count += 1
      
    end
    
  end
  
  it "should create a normalized code automatically when initalized" do
    @ans.code.should eql("no_rarely")
  end
  
end