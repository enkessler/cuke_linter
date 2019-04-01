require 'simplecov'
SimpleCov.command_name('cucumber_tests')

require_relative 'common_env'
require 'cucumber'

require_all 'testing/cucumber/step_definitions'


Before do
  CukeLinter.clear_registered_linters
end

at_exit do
  CukeLinter::FileHelper.created_directories.each do |dir_path|
    FileUtils.remove_entry(dir_path, true)
  end
end
