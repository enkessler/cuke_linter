SimpleCov.command_name(ENV['CUKE_LINTER_SIMPLECOV_COMMAND_NAME'])
SimpleCov.coverage_dir(ENV['CUKE_LINTER_TEST_OUTPUT_DIRECTORY'])

SimpleCov.start do
  root __dir__

  add_filter '/testing/'
  add_filter '/environments/'

  # The HTML formatter is extra noisy and not needed when running the tests in parallel
  formatter SimpleCov::Formatter::SimpleFormatter if ENV['CUKE_LINTER_PARALLEL_RUN']
end
