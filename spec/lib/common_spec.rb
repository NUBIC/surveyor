require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Surveyor::Common, "" do
  it "should convert text to a code that is more appropirate for a database entry" do
    # A few answers from the survey
    { "This? is a in - t3rrible-@nswer of! (question) on" => "this_t3rrible_nswer",
      "Private insurance/ HMO/ PPO" => "private_insurance_hmo_ppo",
      "<bold>VA</bold>" => "va",
      "PMS (Premenstrual syndrome)/ PMDD (Premenstrual Dysphoric Disorder)" => "pms_pmdd",
      "Have never been employed outside the home" => "never_been_employed_outside_home",
      "Professional" => "professional",
      "Not working because of temporary disability, but expect to return to a job" => "temporary_disability_expect_return_job",
      "How long has it been since you last visited a doctor for a routine checkup (routine being not for a particular reason)?" => "visited_doctor_for_routine_checkup",
      "Do you take medications as directed?" => "you_take_medications_as_directed",
      "Do you every leak urine (or) water when you didn't want to?" => "urine_water_you_didnt_want", #checking for () and ' removal
      "Do your biological family members (not adopted) have a \"history\" of any of the following?" => "family_members_history_any_following",
      "Your health:" => "your_health",
      "In general, you would say your health is:" => "you_would_say_your_health"
    }.each{|k, v| Surveyor::Common.to_normalized_string(k).should == v}
  end
  it "should deep compare json objects" do
    a = {"a" => "b"}.to_json
    b = '{"a": "b"}'
    Surveyor::Common.equal_json_excluding_uuids(a,b).should be_true
    
    a = {"y" => "x"}.to_json
    b = {:y => "x"}
    Surveyor::Common.equal_json_excluding_uuids(a,b).should be_true

    a = [{"y" => "x"}, {"j" => "b"}].to_json
    b = '[{"y": "x"}]'
    Surveyor::Common.equal_json_excluding_uuids(a,b).should be_false
    
    a = [{"y" => "x"}, {"uuid" => "*"}].to_json
    b = '[{"y": "x"}, {"uuid": "12312312312123"}]'
    Surveyor::Common.equal_json_excluding_uuids(a,b).should be_true

    a = %({"survey": {
      "title":"Simple survey",
      "uuid":"72888670-9151-012e-9ec1-00254bc472f4",
      "sections":[{
        "title":"Basic questions"
        }]
      }
    })
    b = %({"survey": {"title": "Simple survey","uuid": "*","sections": [{"title": "Basic questions"}]}})
    Surveyor::Common.equal_json_excluding_uuids(a,b).should be_true
  end
  
end