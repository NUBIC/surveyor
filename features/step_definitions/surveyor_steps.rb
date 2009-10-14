Given /^I am a banana$/ do
  @me = "banana"
end

Then /^I should be a banana$/ do
  @me.should == "banana"
end
