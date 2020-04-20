require_relative '../testing/parallel_helper'

namespace 'cuke_linter' do

  desc 'Run all of the Cucumber tests'
  task :run_rspec_tests => [:clear_coverage, :clear_report_directory] do
    puts Rainbow("Running RSpec tests...").cyan

    process = ChildProcess.build('cmd.exe', '/c', 'bundle', 'exec', 'rspec',
                                 '-r', './environments/rspec_env.rb')
    process.io.inherit!
    process.environment['CUKE_LINTER_PARALLEL_RUN'] = 'false'
    process.start
    process.wait

    raise(Rainbow('RSpec tests encountered problems!').red) unless process.exit_code.zero?

    puts Rainbow('All RSpec tests passing. :)').green
  end

  desc 'Run all of the RSpec tests'
  task :run_rspec_tests_in_parallel => [:clear_coverage, :clear_report_directory] do
    puts Rainbow("Running RSpec tests").cyan

    pattern = 'testing/rspec/spec/**/*_spec.rb'
    specs   = CukeLinter::ParallelHelper.get_discrete_specs(spec_pattern: pattern)

    ENV['CUKE_LINTER_PARALLEL_RUN'] ||= 'true'
    CukeLinter::ParallelHelper.run_rspec_in_parallel(spec_list: specs)
  end

  desc 'Run all of the Cucumber tests'
  task :run_cucumber_tests_in_parallel => [:clear_coverage, :clear_report_directory] do
    puts Rainbow("Running Cucumber tests...").cyan

    feature_directory = 'testing/cucumber/features'
    scenarios         = CukeLinter::ParallelHelper.get_discrete_scenarios(directory: feature_directory)

    ENV['CUKE_LINTER_PARALLEL_RUN'] ||= 'true'
    CukeLinter::ParallelHelper.run_cucumber_in_parallel(scenario_list: scenarios)
  end

  desc 'Run all of the Cucumber tests'
  task :run_cucumber_tests => [:clear_coverage, :clear_report_directory] do
    puts Rainbow("Running Cucumber tests...").cyan

    process = ChildProcess.build('cmd.exe', '/c', 'bundle', 'exec', 'cucumber',
                                 '-p', 'default')
    process.io.inherit!
    process.environment['CUKE_LINTER_PARALLEL_RUN'] = 'false'
    process.start
    process.wait

    raise(Rainbow('Cucumber tests encountered problems!').red) unless process.exit_code.zero?

    puts Rainbow('All Cucumber tests passing. :)').green
  end

  desc 'Run all of the tests'
  task :test_everything => [:clear_coverage, :clear_report_directory] do
    begin
      Rake::Task['cuke_linter:run_rspec_tests_in_parallel'].invoke
      Rake::Task['cuke_linter:run_cucumber_tests_in_parallel'].invoke
      Rake::Task['cuke_linter:combine_code_coverage_reports'].invoke
    rescue => e
      puts Rainbow("-----------------------\nSomething isn't right!").red
      puts Rainbow(e.message).yellow
      raise e
    end
  end

end
