When /^I select "([^"]+)" as the datepicker's (\w+)$/ do |selection, type|
  page.find(".ui-datepicker-#{type}").select(selection)
end

When /^I click the first date field$/ do
  first(:css, "input.date[type='text']").click
end

Then /^the first date field should contain "(.*?)"$/ do |value|
  field_value = first(:css, "input.date[type='text']").value
  if field_value.respond_to? :should
    field_value.should =~ /#{value}/
  else
    assert_match(/#{value}/, field_value)
  end
end

Then /^the first date field should not contain "(.*?)"$/ do |value|
  field_value = first(:css, "input.date[type='text']").value
  if field_value.respond_to? :should_not
    field_value.should_not =~ /#{value}/
  else
    assert_no_match(/#{value}/, field_value)
  end
end
