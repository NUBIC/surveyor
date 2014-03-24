# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
begin
  require File.expand_path("../../testbed/config/environment", __FILE__)
rescue LoadError => e
  fail "Could not load the testbed app. Have you generated it?\n#{e.class}: #{e}"
end
require 'rspec/rails'
require 'factories'
require 'json_spec'
require 'database_cleaner'
require 'capybara/rspec'

# for asset_pipeline_enabled? in models
include Surveyor::Helpers::AssetPipeline

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if ::Rails.version >= "4.0" && defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.include JsonSpec::Helpers

  config.treat_symbols_as_metadata_keys_with_true_values = true

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # config.expect_with :rspec do |c|
  #   c.syntax = :expect
  # end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  ## Database Cleaner
  config.before :suite do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before do
    if example.metadata[:js] || example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  config.after do
    DatabaseCleaner.clean
  end
end
