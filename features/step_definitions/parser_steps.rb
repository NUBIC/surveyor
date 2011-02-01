Given /^I parse$|^the survey$/ do |string|
  Surveyor::Parser.parse(string)
end

Given /^I parse redcap file "([^"]*)"$/ do |name|
  Surveyor::RedcapParser.parse File.read(File.join(RAILS_ROOT, '..', 'features', 'support', name)), name
end

Then /^there should be (\d+) survey(?:s?) with:$/ do |x, table|
  Survey.count.should == x.to_i
  table.hashes.each do |hash|
    Survey.find(:first, :conditions => hash).should_not be_nil
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
    Question.find(:first, :conditions => hash).should_not be_nil
  end
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
