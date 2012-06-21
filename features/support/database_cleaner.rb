require 'database_cleaner'

# Use transaction cleaning for performance by default
DatabaseCleaner.strategy = :transaction
# Clean to start so that manual testing data in testbed can't cause false
# test results.
DatabaseCleaner.clean_with(:truncation)

# use truncation to allow direct DB checks in Selenium tests
Before('@javascript') do
  DatabaseCleaner.strategy = :truncation
end

After('@javascript') do
  DatabaseCleaner.strategy = :transaction
end
