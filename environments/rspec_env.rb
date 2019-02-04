require_relative 'common_env'
require 'rspec'

require_relative '../testing/rspec/spec/unit/formatters/formatter_unit_specs'
require_relative '../testing/rspec/spec/integration/formatters/formatter_integration_specs'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end


  config.after(:suite) do
    CukeLinter::FileHelper.created_directories.each do |dir_path|
      FileUtils.remove_entry(dir_path, true)
    end
  end

end
