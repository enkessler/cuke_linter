if ENV['CUKE_LINTER_PARALLEL_RUN'] == 'true'
  part_number                               = ENV['CUKE_LINTER_PARALLEL_PROCESS_COUNT'] # rubocop:disable Layout/SpaceAroundOperators, Metrics/LineLength
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME'] ||= "rspec_tests_part_#{part_number}"
  ENV['CUKE_LINTER_TEST_OUTPUT_DIRECTORY']  ||= "testing/reports/rspec/part_#{part_number}/coverage"
else
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME'] ||= 'rspec_tests'
  ENV['CUKE_LINTER_TEST_OUTPUT_DIRECTORY']  ||= 'coverage'
end

# Unless otherwise set, assume that this file is only loaded during testing
ENV['CUKE_LINTER_TEST_PROCESS'] ||= 'true'

require 'simplecov'
require_relative 'common_env'
require 'rspec'
require 'rubygems/mock_gem_ui'
require 'yaml'

require_relative '../testing/rspec/spec/unit/formatters/formatter_unit_specs'
require_relative '../testing/rspec/spec/unit/linters/configurable_linter_unit_specs'
require_relative '../testing/rspec/spec/unit/linters/linter_unit_specs'
require_relative '../testing/rspec/spec/integration/formatters/formatter_integration_specs'
require_relative '../testing/rspec/spec/integration/linters/linter_integration_specs'

# Convenient constants, just in case what kinds of elements are taggable ever changes
TAGGABLE_ELEMENTS               = ['feature', 'scenario', 'outline', 'example']
ELEMENTS_WITH_TAGGABLE_CHILDREN = ['feature', 'outline']

RSpec.configure do |config|

  if ENV['CUKE_LINTER_PARALLEL_RUN'] == 'true'
    process_count    = ENV['CUKE_LINTER_PARALLEL_PROCESS_COUNT']
    source_file      = "testing/reports/rspec/part_#{process_count}/test_list_#{process_count}.txt"
    persistence_file = "testing/reports/rspec/part_#{process_count}/.rspec_status_#{process_count}"
    spec_list        = File.read(source_file).split("\n")
    config.instance_variable_set(:@files_or_directories_to_run, spec_list)
  else
    config.pattern    = 'testing/rspec/spec/**/*_spec.rb'
    config.color_mode = :on
    persistence_file  = '.rspec_status'
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = persistence_file

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    # Using a global variable instead of an instance variable because instance variables
    # are not compatible with :suite hooks
    $default_linters = Marshal.load(Marshal.dump(CukeLinter.registered_linters))
  end

  # Restore the original linters after any test that modifies them so that other tests can
  # rely on them being only the default ones
  config.after(:example, :linter_registration) do
    CukeLinter.clear_registered_linters

    $default_linters.each_pair do |name, linter|
      CukeLinter.register_linter(name: name, linter: linter)
    end
  end

  config.after(:suite) do
    CukeLinter::FileHelper.created_directories.each do |dir_path|
      FileUtils.remove_entry(dir_path, true)
    end
  end

  config.include CukeLinter::FileHelper
  config.include CukeLinter::FormatterFactory
  config.include CukeLinter::LinterFactory
  config.include CukeLinter::ModelFactory
end
