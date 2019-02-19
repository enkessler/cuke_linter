require 'simplecov'
SimpleCov.command_name('cucumber_tests')

require_relative 'common_env'
require 'cucumber'

require_all 'testing/cucumber/step_definitions'
