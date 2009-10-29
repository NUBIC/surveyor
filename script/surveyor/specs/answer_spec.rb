require File.dirname(__FILE__) + '/../answer'

describe Answer, " when first created" do

  before do
    question = mock("Question", :id => 2, :parser => mock("Parser", :new_answer_id => 1))
    args = {:text => "No / Rarely", :help_text => "Never or rarely ever", :reference_identifier => "b3a_1"}
    options = {}
    @ans = Answer.new(question, args, options)
  end
  
  it "should set inititalized variables to those passed in" do
    @ans.id.should == 1
    @ans.question_id.should == 2
    @ans.reference_identifier.should == "b3a_1"
    @ans.text.should == "No / Rarely"
    @ans.help_text.should == "Never or rarely ever"
    end
  
  it "should output current state to yml" do
     @ans.should.respond_to?(:to_yml)
  end
  
  it "should create a normalized code from the answer text" do
    # The answer object should take the title of the text and convert it to a code that is more appropirate for a database entry
    
    # Taking a few answers from the survey for testing
    strings = [ "This? is a in - t3rrible-@nswer of! (question) on",
                "Private insurance/ HMO/ PPO",
                "VA",
                "PMS (Premenstrual syndrome)/ PMDD (Premenstrual Dysphoric Disorder)",
                "Have never been employed outside the home",
                "Professional",
                "Not working because of temporary disability, but expect to return to a job" ]
    
    # What the results should look like
    codes = [ "this_t3rrible_nswer",
              "private_insurance_hmo_ppo",
              "va",
              "pms_pmdd",
              "never_been_employed_outside_home",
              "professional",
              "temporary_disability_expect_return_job" ]
    
    require File.dirname(__FILE__) + '/../../../lib/tiny_code'
    strings.each_with_index do |s, i|
      Columnizer.to_normalized_column(s).should == codes[i]
    end
  end
  
  it "should create a normalized code automatically when initalized" do
    @ans.data_export_identifier.should eql("no_rarely")
  end
  
end