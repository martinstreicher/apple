# frozen_string_literal: true

require 'action_mailbox/test_helper'

RSpec.configure do |config|
  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end

  config.example_status_persistence_file_path = 'spec/failures.txt'
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.filter_run focus: true
  config.formatter = :documentation

  config.include ActionMailbox::TestHelper, type: :mailbox
  config.include FactoryBot::Syntax::Methods

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.profile_examples = 10
  config.run_all_when_everything_filtered = true
  config.shared_context_metadata_behavior = :apply_to_host_groups

  Kernel.srand config.seed
end
