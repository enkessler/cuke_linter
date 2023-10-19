# Because this file gets automatically loaded when the SimpleCov gem is first required (which
# is done as part of doing pretty much anything in the project) only actually start tracking
# code coverage if testing is happening.
if ENV['CUKE_LINTER_TEST_PROCESS'] == 'true'
  require 'simplecov-lcov'

  SimpleCov.command_name(ENV.fetch('CUKE_LINTER_SIMPLECOV_COMMAND_NAME'))
  SimpleCov.coverage_dir(ENV.fetch('CUKE_LINTER_SIMPLECOV_OUTPUT_DIRECTORY'))

  SimpleCov::Formatter::LcovFormatter.config do |config|
    config.report_with_single_file = true
    config.lcov_file_name = 'lcov.info'
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter,
                                                                  SimpleCov::Formatter::LcovFormatter])

  SimpleCov.start do
    root __dir__

    add_filter '/testing/'
  end
end
