require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor do
  it "should create a normalized code from the answer text" do
    # The answer object should take the title of the text and convert it to a code that is more appropirate for a database entry
    


        
    # Taking a few answers from the survey for testing
    strings = [ "This? is a in - t3rrible-@nswer of! (question) on",
                "Private insurance/ HMO/ PPO",
                "<bold>VA</bold>",
                "PMS (Premenstrual syndrome)/ PMDD (Premenstrual Dysphoric Disorder)",
                "Have never been employed outside the home",
                "Professional",
                "Not working because of temporary disability, but expect to return to a job",
                "How long has it been since you last visited a doctor for a routine checkup (routine being not for a particular reason)?",
                "Do you take medications as directed?",
                "Do you every leak urine (or) water when you didn't want to?", #checking for () and ' removal
                "Do your biological family members (not adopted) have a \"history\" of any of the following?",
                "Your health:",
                "In general, you would say your health is:" ]
    
    # What the results should look like
    codes = [ "this_t3rrible_nswer",
              "private_insurance_hmo_ppo",
              "va",
              "pms_pmdd",
              "never_been_employed_outside_home",
              "professional",
              "temporary_disability_expect_return_job",              
              "visited_doctor_for_routine_checkup",
              "you_take_medications_as_directed",
              "urine_water_you_didnt_want",
              "family_members_history_any_following",
              "your_health",
              "you_would_say_your_health" ]
    
    strings.each_with_index do |s, i|
      Surveyor::Common.to_normalized_string(s).should == codes[i]
    end
  end
end