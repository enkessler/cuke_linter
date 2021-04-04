if ENV['CUKE_LINTER_PARALLEL_RUN'] == 'true'
  part_number                                   = ENV['CUKE_LINTER_PARALLEL_PROCESS_COUNT']
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME']     = "cucumber_tests_part_#{part_number}"
  ENV['CUKE_LINTER_SIMPLECOV_OUTPUT_DIRECTORY'] = "#{ENV['CUKE_LINTER_REPORT_FOLDER']}/cucumber/part_#{part_number}/coverage"
else
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME']     = 'cucumber_tests'
  ENV['CUKE_LINTER_SIMPLECOV_OUTPUT_DIRECTORY'] = "#{ENV['CUKE_LINTER_REPORT_FOLDER']}/coverage"
end

# Unless otherwise set, assume that this file is only loaded during testing
ENV['CUKE_LINTER_TEST_PROCESS'] ||= 'true'
require 'simplecov'
require_relative 'common_env'
require 'cucumber'

require_all 'testing/cucumber/step_definitions'

World(CukeLinter::FileHelper)
World(CukeLinter::FormatterFactory)
World(CukeLinter::LinterFactory)

Before do
  CukeLinter.clear_registered_linters
end

Before do
  @root_test_directory = create_directory
end

at_exit do
  CukeLinter::FileHelper.created_directories.each do |dir_path|
    FileUtils.remove_entry(dir_path, true)
  end
end
