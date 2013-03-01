Given /^I parse$/ do |string|
  Surveyor::Parser.parse(string)
end

Given /^the survey$/ do |string|
  @survey_string = string
end

Then /^the parser should fail with "(.*)"$/ do |error_message|
  lambda { Surveyor::Parser.parse(@survey_string) }.should raise_error(Surveyor::ParserError, /#{error_message}/)
end

Given /^the questions?$/ do |q_string|
  Surveyor::Parser.parse(<<-SURVEY)
    survey "Some questions for you" do
      section "All the questions" do
        #{q_string}
      end
    end
  SURVEY
end

Given /^I parse redcap file "(.*)"$/ do |name|
  Surveyor::RedcapParser.parse File.read(File.join(Rails.root, '..', 'features', 'support', name)), name
end

Then /^there should be (\d+) survey(?:s?) with:$/ do |x, table|
  Survey.count.should == x.to_i
  table.hashes.each do |hash|
    Survey.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) translations with$/ do |x, table|
  SurveyTranslation.count.should == x.to_i
  table.hashes.each do |hash|
    SurveyTranslation.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) section(?:s?) with:$/ do |x, table|
  SurveySection.count.should == x.to_i
  table.hashes.each do |hash|
    SurveySection.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) question groups with:$/ do |x, table|
  QuestionGroup.count.should == x.to_i
  table.hashes.each do |hash|
    QuestionGroup.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) question(?:s?) with:$/ do |x, table|
  Question.count.should == x.to_i
  table.hashes.each do |hash|
    hash["reference_identifier"] = nil if hash["reference_identifier"] == "nil"
    hash["custom_class"] = nil if hash["custom_class"] == "nil"
    if hash.has_key?("is_mandatory")
      hash["is_mandatory"] = (hash["is_mandatory"] == "true" ? true : (hash["is_mandatory"] == "false" ? false : hash["is_mandatory"]))
    end
    result = Question.find(:first, :conditions => hash)
    puts hash if result.nil?
    result.should_not be_nil
  end
end

Then /^there should be (\d+) question(?:s?) with a correct answer$/ do |x|
  Question.count(:conditions => "correct_answer_id NOT NULL").should == x.to_i
  Question.all(:conditions => "correct_answer_id NOT NULL").compact.map(&:correct_answer).compact.size.should == x.to_i
end

Then /^there should be (\d+) answer(?:s?) with:$/ do |x, table|
  Answer.count.should == x.to_i
  table.hashes.each do |hash|
    hash["reference_identifier"] = nil if hash["reference_identifier"] == "nil"
    Answer.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) dependenc(?:y|ies) with:$/ do |x, table|
  Dependency.count.should == x.to_i
  table.hashes.each do |hash|
    Dependency.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) resolved dependency_condition(?:s?) with:$/ do |x, table|
  DependencyCondition.count.should == x.to_i
  table.hashes.each do |hash|
    d = DependencyCondition.find(:first, :conditions => hash)
    d.should_not be_nil
    d.question.should_not be_nil
    d.answer.should_not be_nil unless d.operator.match(/^count[<>=!]{1,2}\d+/)
  end
end


Then /^there should be (\d+) validation(?:s?) with:$/ do |x, table|
  Validation.count.should == x.to_i
  table.hashes.each do |hash|
    Validation.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) validation_condition(?:s?) with:$/ do |x, table|
  ValidationCondition.count.should == x.to_i
  table.hashes.each do |hash|
    hash["integer_value"] = nil if hash["integer_value"] == "nil"
    ValidationCondition.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^question "([^"]*)" should have correct answer "([^"]*)"$/ do |qr, ar|
  (q = Question.find_by_reference_identifier(qr)).should_not be_nil
  q.correct_answer.should == q.answers.find_by_reference_identifier(ar)
end

Then /^(\d+) dependencies should depend on questions$/ do |x|
  arr = Dependency.find_all_by_question_group_id(nil)
  arr.size.should == 2
  arr.each{|d| d.question.should_not be_nil}
end

Then /^(\d+) dependencies should depend on question groups$/ do |x|
  arr = Dependency.find_all_by_question_id(nil)
  arr.size.should == 2
  arr.each{|d| d.question_group.should_not be_nil}
end
