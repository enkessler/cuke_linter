require 'tempfile'
require 'rspec'
require 'rspec/core/formatters/json_formatter'
require 'parallel'
require 'open3'
require 'childprocess'
require 'cuke_slicer'

# This file is loaded as part of the project framework, not during tests
ENV['CUKE_LINTER_TEST_PROCESS'] = 'false'
require 'simplecov'
require 'simplecov-lcov'

module CukeLinter

  # TODO: Maybe address this later
  # rubocop:disable Metrics/ModuleLength

  # A helper module that has methods for doing testing in parallel
  module ParallelHelper

    include CukeLinterHelper

    def get_discrete_specs # rubocop:disable Naming/AccessorMethodName -- This is not that.
      puts 'Gathering specs...'

      temp_file_path = Tempfile.new(['cuke_linter', '.json']).path
      process = run_spec_gathering_process(temp_file_path)

      raise(Rainbow('Could not gather specs!').red) unless process.exit_code.zero?

      JSON.parse(File.read(temp_file_path))['examples'].collect { |example| example['id'] }
    end

    def run_rspec_in_parallel(spec_list:, parallel_count: Parallel.processor_count)
      run_tests_in_parallel(test_list: spec_list, parallel_count: parallel_count, test_type: 'rspec')
    end

    def get_discrete_scenarios(directory:)
      filters = { excluded_tags: ['@wip'] }
      CukeSlicer::Slicer.new.slice(directory, filters, :file_line)
    end

    def run_cucumber_in_parallel(scenario_list:, parallel_count: Parallel.processor_count)
      run_tests_in_parallel(test_list: scenario_list, parallel_count: parallel_count, test_type: 'cucumber')
    end

    def combine_code_coverage_reports # rubocop:disable Metrics/AbcSize, Metrics/MethodLength -- It'll get better when support for older versions of Ruby is dropped.
      all_results = Dir["#{ENV.fetch('CUKE_LINTER_REPORT_FOLDER')}/{rspec,cucumber}/part_*/coverage/.resultset.json"]

      # Never versions of SimpleCov make combining reports a lot easier
      if SimpleCov.respond_to?(:collate)
        SimpleCov::Formatter::LcovFormatter.config do |config|
          config.report_with_single_file = true
          config.lcov_file_name = 'lcov.info'
        end

        SimpleCov.collate(all_results) do
          coverage_dir("#{ENV.fetch('CUKE_LINTER_REPORT_FOLDER')}/coverage")
          formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter,
                                                              SimpleCov::Formatter::LcovFormatter])
        end
      else
        result_objects = all_results.map do |result_file_name|
          SimpleCov::Result.from_hash(JSON.parse(File.read(result_file_name)))
        end
        merged_result = SimpleCov::ResultMerger.merge_results(*result_objects)


        # Set overall coverage report folder
        SimpleCov.coverage_dir("#{ENV.fetch('CUKE_LINTER_REPORT_FOLDER')}/coverage")

        # Create the LCOV report
        SimpleCov::Formatter::LcovFormatter.config do |config|
          config.report_with_single_file = true
          config.lcov_file_name = 'lcov.info'
        end

        SimpleCov::Formatter::LcovFormatter.new.format(merged_result)


        # Creates the HTML report
        merged_result.format!

        # Creates the finalized JSON file that Coveralls will need
        SimpleCov::ResultMerger.store_result(merged_result)
      end
    end


    private


    def parallel_folder_path_for(test_type:, process_number:)
      "#{ENV.fetch('CUKE_LINTER_REPORT_FOLDER')}/#{test_type}/part_#{process_number}"
    end

    def run_spec_gathering_process(gathering_file_path)
      run_command(['bundle', 'exec', 'rspec',
                   '--pattern', CukeLinter::CukeLinterHelper.rspec_test_file_pattern,
                   '--dry-run'],
                  env_vars:    { CUKE_LINTER_SIMPLECOV_COMMAND_NAME:      'rspec_spec_gathering',
                                 CUKE_LINTER_TEST_PROCESS:                'false',
                                 CUKE_LINTER_RSPEC_REPORT_JSON_FILE_PATH: gathering_file_path },
                  pipe_output: false)
    end

    def create_process_test_files(test_list, parallel_count, test_type)
      # Round-robin split so that long-running tests in the suite (either evening distributed
      # or in clusters) are less likely to be grouped in the split files
      process_test_lists = Array.new(parallel_count) { [] }

      test_list.each_with_index do |test, index|
        process_test_lists[index % parallel_count] << test
      end

      process_test_lists.each_with_index do |process_test_list, index|
        directory = parallel_folder_path_for(test_type: test_type, process_number: index + 1)
        file_path = "test_list_#{index + 1}.txt"
        FileUtils.mkpath(directory)
        File.write("#{directory}/#{file_path}", process_test_list.join("\n"))
      end
    end

    def generate_processes(parallel_count, test_type) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength -- Some day I might worry about this. Today is not that day.
      [].tap do |processes|
        parallel_count.times do |process_count|
          directory = parallel_folder_path_for(test_type: test_type, process_number: process_count + 1)
          stdout_file_name = "std_out_#{process_count + 1}.txt"
          stderr_file_name = "std_err_#{process_count + 1}.txt"
          stdout_file_path = "#{directory}/#{stdout_file_name}"
          stderr_file_path = "#{directory}/#{stderr_file_name}"

          process = send("create_parallel_#{test_type}_process", process_count, directory)

          FileUtils.touch(stdout_file_path)
          FileUtils.touch(stderr_file_path)
          process.io.stdout = File.new(stdout_file_path, 'w')
          process.io.stderr = File.new(stderr_file_path, 'w')
          process.environment['CUKE_LINTER_PARALLEL_PROCESS_COUNT'] = process_count + 1
          process.environment['CUKE_LINTER_PARALLEL_FOLDER'] = directory
          process.environment['CUKE_LINTER_PARALLEL_RUN'] = 'true'
          process.environment['CUKE_LINTER_TEST_PROCESS'] = 'true'
          process.start
          processes << process
        end
      end
    end

    def run_tests_in_parallel(test_list:, test_type:, parallel_count: Parallel.processor_count)
      create_process_test_files(test_list, parallel_count, test_type)

      puts "Running #{test_list.count} tests across #{parallel_count} processes..."

      processes = generate_processes(parallel_count, test_type)
      problem_process_groups = gather_process_results(processes)
      handle_bad_results(problem_process_groups, test_type) if problem_process_groups.any?

      puts Rainbow("All #{test_type.capitalize} tests passing. :)").green
    end

    def gather_process_results(processes)
      [].tap do |problem_process_groups|
        processes.each_with_index do |process, index|
          process.wait
          problem_process_groups << (index + 1) unless process.exit_code.zero?
        end
      end
    end

    def handle_bad_results(problem_process_groups, test_type)
      display_problems(problem_process_groups, test_type)
      error_message = "#{test_type.capitalize} tests encountered problems! (see reports for groups #{problem_process_groups}" # rubocop:disable Layout/LineLength
      raise(Rainbow(error_message).red)
    end

    def create_parallel_rspec_process(process_count, directory)
      json_file_path = "#{directory}/results_#{process_count + 1}.json"
      html_file_path = "#{directory}/results_#{process_count + 1}.html"

      create_process(['bundle', 'exec', 'rspec'],
                     env_vars: { CUKE_LINTER_RSPEC_REPORT_JSON_FILE_PATH: json_file_path,
                                 CUKE_LINTER_RSPEC_REPORT_HTML_FILE_PATH: html_file_path })
    end

    def create_parallel_cucumber_process(process_count, directory)
      json_file_path = "#{directory}/results_#{process_count + 1}.json"
      html_file_path = "#{directory}/results_#{process_count + 1}.html"

      create_process(['bundle', 'exec', 'cucumber',
                      '-p', 'parallel'],
                     env_vars: { CUKE_LINTER_CUCUMBER_REPORT_JSON_FILE_PATH: json_file_path,
                                 CUKE_LINTER_CUCUMBER_REPORT_HTML_FILE_PATH: html_file_path })
    end

    def display_problems(problem_process_groups, test_type)
      puts Rainbow('Dumping output for errored processes...').yellow

      problem_process_groups.each do |process_number|
        puts Rainbow("Dumping output for process #{process_number}...").yellow

        directory = parallel_folder_path_for(test_type: test_type, process_number: process_number)
        stdout_file_name = "std_out_#{process_number}.txt"
        stdout_file_path = "#{directory}/#{stdout_file_name}"

        process_output = File.read(stdout_file_path)
        puts Rainbow(process_output).cyan
      end
    end

    extend self

  end
  # rubocop:enable Metrics/ModuleLength

end
