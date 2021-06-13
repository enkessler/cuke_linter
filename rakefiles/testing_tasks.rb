require_relative '../cuke_linter_helper'
require_relative '../testing/parallel_helper'

namespace 'cuke_linter' do # rubocop:disable Metrics/BlockLength

  desc 'Run all of the RSpec tests'
  task :run_rspec_tests => [:clear_old_results] do # rubocop:disable Style/HashSyntax
    puts Rainbow('Running RSpec tests...').cyan

    completed_process = CukeLinter::CukeLinterHelper.run_command(['bundle', 'exec', 'rspec',
                                                                  '--pattern', CukeLinter::CukeLinterHelper.rspec_test_file_pattern], # rubocop:disable Metrics/LineLength
                                                                 env_vars: { CUKE_LINTER_PARALLEL_RUN: 'false',
                                                                             CUKE_LINTER_TEST_PROCESS: 'true' })

    raise(Rainbow('RSpec tests encountered problems!').red) unless completed_process.exit_code.zero?

    puts Rainbow('All RSpec tests passing. :)').green
  end

  desc 'Run all of the RSpec tests'
  task :run_rspec_tests_in_parallel => [:clear_old_results] do # rubocop:disable Style/HashSyntax
    puts Rainbow('Running RSpec tests in parallel...').cyan

    specs = CukeLinter::ParallelHelper.get_discrete_specs

    CukeLinter::ParallelHelper.run_rspec_in_parallel(spec_list: specs)
  end

  desc 'Run all of the Cucumber tests'
  task :run_cucumber_tests_in_parallel => [:clear_old_results] do # rubocop:disable Style/HashSyntax
    puts Rainbow('Running Cucumber tests in parallel...').cyan

    feature_directory = 'testing/cucumber/features'
    scenarios = CukeLinter::ParallelHelper.get_discrete_scenarios(directory: feature_directory)

    CukeLinter::ParallelHelper.run_cucumber_in_parallel(scenario_list: scenarios)
  end

  desc 'Run all of the Cucumber tests'
  task :run_cucumber_tests => [:clear_old_results] do # rubocop:disable Style/HashSyntax
    puts Rainbow('Running Cucumber tests...').cyan

    completed_process = CukeLinter::CukeLinterHelper.run_command(['bundle', 'exec', 'cucumber'],
                                                                 env_vars: { CUKE_LINTER_PARALLEL_RUN: 'false',
                                                                             CUKE_LINTER_TEST_PROCESS: 'true' })

    raise(Rainbow('Cucumber tests encountered problems!').red) unless completed_process.exit_code.zero?

    puts Rainbow('All Cucumber tests passing. :)').green
  end

  desc 'Run all of the tests'
  task :test_everything => [:clear_old_results] do # rubocop:disable Style/HashSyntax
    puts Rainbow('Running tests...').cyan

    begin
      # JRuby doesn't seem to work reliably with the parallel process approach
      if ChildProcess.jruby?
        Rake::Task['cuke_linter:run_rspec_tests'].invoke
        Rake::Task['cuke_linter:run_cucumber_tests'].invoke
      else
        Rake::Task['cuke_linter:run_rspec_tests_in_parallel'].invoke
        Rake::Task['cuke_linter:run_cucumber_tests_in_parallel'].invoke
        Rake::Task['cuke_linter:combine_code_coverage_reports'].invoke
      end
    rescue => e
      puts Rainbow("-----------------------\nSomething isn't right!").red
      puts Rainbow(e.message).yellow
      raise e
    end

    puts Rainbow('All tests passing!').green
  end

end
