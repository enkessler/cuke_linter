if ENV['CUKE_LINTER_PARALLEL_RUN'] == 'true'
  part_number                                   = ENV.fetch('CUKE_LINTER_PARALLEL_PROCESS_COUNT') # rubocop:disable Layout/SpaceAroundOperators
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME']     ||= "rspec_tests_part_#{part_number}"
  ENV['CUKE_LINTER_SIMPLECOV_OUTPUT_DIRECTORY'] ||= "#{ENV.fetch('CUKE_LINTER_REPORT_FOLDER')}/rspec/part_#{part_number}/coverage" # rubocop:disable Layout/LineLength
else
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME']     ||= 'rspec_tests'
  ENV['CUKE_LINTER_SIMPLECOV_OUTPUT_DIRECTORY'] ||= "#{ENV.fetch('CUKE_LINTER_REPORT_FOLDER')}/coverage"
end

# Unless otherwise set, assume that this file is only loaded during testing
ENV['CUKE_LINTER_TEST_PROCESS'] ||= 'true'
require 'simplecov'
require_relative 'common_env'
require 'rspec'
require 'yaml'

require_relative '../rspec/spec/unit/formatters/formatter_unit_specs'
require_relative '../rspec/spec/unit/linters/configurable_linter_unit_specs'
require_relative '../rspec/spec/unit/linters/linter_unit_specs'
require_relative '../rspec/spec/integration/formatters/formatter_integration_specs'
require_relative '../rspec/spec/integration/linters/linter_integration_specs'

# Convenient constants, just in case what kinds of elements are taggable ever changes
TAGGABLE_ELEMENTS               = %w[feature scenario outline example].freeze
ELEMENTS_WITH_TAGGABLE_CHILDREN = %w[feature outline].freeze

DEFAULT_LINTERS = Marshal.load(Marshal.dump(CukeLinter.registered_linters)).freeze

# rubocop:disable Metrics/BlockLength
RSpec.configure do |config|

  if ENV['CUKE_LINTER_PARALLEL_RUN'] == 'true'
    process_count    = ENV.fetch('CUKE_LINTER_PARALLEL_PROCESS_COUNT')
    source_file      = "#{ENV.fetch('CUKE_LINTER_PARALLEL_FOLDER')}/test_list_#{process_count}.txt"
    persistence_file = "#{ENV.fetch('CUKE_LINTER_PARALLEL_FOLDER')}/.rspec_status_#{process_count}"
    spec_list        = File.read(source_file).split("\n")
    config.instance_variable_set(:@files_or_directories_to_run, spec_list)
  else
    config.color_mode = :on
    persistence_file  = "#{ENV.fetch('CUKE_LINTER_REPORT_FOLDER')}/.rspec_status"
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = persistence_file

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # For running only specific tests with the 'focus' tag
  config.filter_run_when_matching focus: true

  # Restore the original linters after any test that modifies them so that other tests can
  # rely on them being only the default ones
  config.after(:example, :linter_registration) do
    CukeLinter.clear_registered_linters

    DEFAULT_LINTERS.each_pair do |name, linter|
      CukeLinter.register_linter(name: name, linter: linter)
    end
  end

  config.after(:suite) do
    CukeLinter::FileHelper.created_directories.each do |dir_path|
      FileUtils.remove_entry(dir_path, true)
    end
  end

  # Methods will be available outside of tests
  include CukeLinter::HelperMethods

  # Methods will be available inside of tests
  config.include CukeLinter::FileHelper
  config.include CukeLinter::FormatterFactory
  config.include CukeLinter::LinterFactory
  config.include CukeLinter::ModelFactory
end
# rubocop:enable Metrics/BlockLength
