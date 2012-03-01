When /^I wait (\d+) seconds$/ do |wait_seconds|
  sleep(wait_seconds.to_i)
end