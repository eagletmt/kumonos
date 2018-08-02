# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'kumonos'

require 'jsonnet'
require 'rspec/json_matcher'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'tmp/examples.txt'
  config.disable_monkey_patching!
  config.warnings = false

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.include RSpec::JsonMatcher
end
