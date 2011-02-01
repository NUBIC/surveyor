When /^I start the "([^"]*)" survey$/ do |name|
  When "I go to the surveys page"
  Then "I should see \"#{name}\""
  click_button "Take it"
end

Then /^there should be (\d+) response set with (\d+) responses with:$/ do |rs_num, r_num, table|
  ResponseSet.count.should == rs_num.to_i
  Response.count.should == r_num.to_i
  # table is a Cucumber::Ast::Table
end
