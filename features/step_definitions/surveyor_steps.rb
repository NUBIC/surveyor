Given /^I parse$/ do |string|
  Surveyor::Parser.parse(string)
end

Then /^there should be (\d+) survey(?:s?) with:$/ do |x, table|
  Survey.count.should == x.to_i
  table.hashes.each do |hash|
    Survey.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) question(?:s?) with:$/ do |x, table|
  Question.count.should == x.to_i
  table.hashes.each do |hash|
    Question.find(:first, :conditions => hash).should_not be_nil
  end
end

Then /^there should be (\d+) answer(?:s?) with:$/ do |x, table|
  Answer.count.should == x.to_i
  table.hashes.each do |hash|
    Answer.find(:first, :conditions => hash).should_not be_nil
  end
end