require File.expand_path(File.dirname(__FILE__) + '/../columnizer')

describe Columnizer do
  it "should create a normalized code from the answer text" do
    # The answer object should take the title of the text and convert it to a code that is more appropirate for a database entry
    
    # Taking a few answers from the survey for testing
    strings = [ "This? is a in - t3rrible-@nswer of! (question) on",
                "Private insurance/ HMO/ PPO",
                "<bold>VA</bold>",
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
    
    strings.each_with_index do |s, i|
      Columnizer.to_normalized_column(s).should == codes[i]
    end
  end
end