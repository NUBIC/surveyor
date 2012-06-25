When /^I select "([^"]+)" as the datepicker's (\w+)$/ do |selection, type|
  page.find(".ui-datepicker-#{type}").select(selection)
end
