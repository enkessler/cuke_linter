require 'simplecov'
SimpleCov.command_name('rspec_tests')

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
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    # Using a global variable instead of an instance variable because instance variables are not compatible with :suite hooks
    $default_linters = Marshal.load(Marshal.dump(CukeLinter.registered_linters))
  end

  # Restore the original linters after any test that modifies them so that other tests can rely on them being only the default ones
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

end
