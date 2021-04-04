# Because this file gets automatically loaded when the SimpleCov gem is first required (which
# is done as part of doing pretty much anything in the project) only actually start tracking
# code coverage if testing is happening.
if ENV['CUKE_LINTER_TEST_PROCESS'] == 'true'
  SimpleCov.command_name(ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME'])
  SimpleCov.coverage_dir(ENV['CUKE_LINTER_SIMPLECOV_OUTPUT_DIRECTORY'])

  SimpleCov.start do
    root __dir__

    add_filter '/testing/'
    add_filter '/environments/'

    # The HTML formatter is extra noisy and not needed when running the tests in parallel
    formatter SimpleCov::Formatter::SimpleFormatter if ENV['CUKE_LINTER_PARALLEL_RUN'] == 'true'
  end
end
