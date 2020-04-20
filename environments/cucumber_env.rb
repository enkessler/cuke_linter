if ENV['CUKE_LINTER_PARALLEL_RUN']
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME'] = "cucumber_tests_part_#{ENV['CUKE_LINTER_PARALLEL_PROCESS_COUNT']}"
  ENV['CUKE_LINTER_TEST_OUTPUT_DIRECTORY']  = "testing/reports/cucumber/part_#{ENV['CUKE_LINTER_PARALLEL_PROCESS_COUNT']}/coverage"
else
  ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME'] = 'cucumber_tests'
  ENV['CUKE_LINTER_TEST_OUTPUT_DIRECTORY']  = 'coverage'
end

require 'simplecov'
require_relative 'common_env'
require 'cucumber'

require_all 'testing/cucumber/step_definitions'


Before do
  CukeLinter.clear_registered_linters
end

Before do
  @root_test_directory = CukeLinter::FileHelper.create_directory
end

at_exit do
  CukeLinter::FileHelper.created_directories.each do |dir_path|
    FileUtils.remove_entry(dir_path, true)
  end
end
