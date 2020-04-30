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

module CukeLinter

  # A helper module that has methods for doing testing in parallel

  module ParallelHelper

    REPORT_FOLDER = "#{__dir__}/reports".freeze

    def self.included(klass)
      klass.include(Methods)
    end

    def self.extended(klass)
      klass.extend(Methods)
    end

    module Methods

      include ProcessHelper

      def get_discrete_specs(spec_pattern:)
        puts "Gathering specs..."

        temp_file = Tempfile.new
        process   = create_process('bundle', 'exec', 'rspec',
                                   '--pattern', spec_pattern,
                                   '--dry-run',
                                   '-r', './environments/rspec_env.rb',
                                   '--format', 'RSpec::Core::Formatters::JsonFormatter', '--out', temp_file.path)
        process.io.inherit!
        process.environment['CUKE_LINTER_SIMPLECOV_COMMAND_NAME'] = 'rspec_spec_gathering'
        process.environment['CUKE_LINTER_TEST_PROCESS']           = 'false'
        process.start
        process.wait

        raise(Rainbow('Could not gather specs!').red) unless process.exit_code.zero?

        JSON.parse(File.read(temp_file.path))['examples'].collect { |example| example['id'] }
      end

      def run_rspec_in_parallel(spec_list:, parallel_count: Parallel.processor_count)
        create_process_test_files(spec_list, parallel_count, 'rspec')

        Kernel.puts "Running #{spec_list.count} specs across #{parallel_count} processes..."

        processes              = generate_processes(parallel_count, 'rspec')
        problem_process_groups = []

        processes.each_with_index do |process, index|
          process.wait
          problem_process_groups << index + 1 unless process.exit_code.zero?
        end

        if problem_process_groups.any?
          display_problems(problem_process_groups, 'rspec')
          raise(Rainbow("RSpec tests encountered problems! (see reports for groups #{problem_process_groups}").red)
        end

        puts Rainbow('All RSpec tests passing. :)').green
      end

      def get_discrete_scenarios(directory:)
        filters = { excluded_tags: ['@wip'] }
        CukeSlicer::Slicer.new.slice(directory, filters, :file_line)
      end

      def run_cucumber_in_parallel(scenario_list:, parallel_count: Parallel.processor_count)
        create_process_test_files(scenario_list, parallel_count, 'cucumber')

        puts "Running #{scenario_list.count} scenarios across #{parallel_count} processes..."

        processes              = generate_processes(parallel_count, 'cucumber')
        problem_process_groups = []

        processes.each_with_index do |process, index|
          process.wait
          problem_process_groups << index + 1 unless process.exit_code.zero?
        end

        if problem_process_groups.any?
          display_problems(problem_process_groups, 'cucumber')
          raise(Rainbow("Cucumber tests encountered problems! (see reports for groups #{problem_process_groups}").red)
        end

        puts Rainbow('All Cucumber tests passing. :)').green
      end

      def combine_code_coverage_reports
        all_results = Dir["#{REPORT_FOLDER}/{rspec,cucumber}/part_*/coverage/.resultset.json"]

        result_objects = []
        all_results.each do |result_file_name|
          result_objects << SimpleCov::Result.from_hash(JSON.parse(File.read(result_file_name)))
        end
        merged_result = SimpleCov::ResultMerger.merge_results(*result_objects)

        # Creates the HTML report
        merged_result.format!

        # Creates the finalized JSON file that Coveralls will need
        SimpleCov::ResultMerger.store_result(merged_result)
      end


      private


      def create_process_test_files(test_list, parallel_count, test_type)
        # Round-robin split so that long-running tests in the suite (either evening distributed
        # or in clusters) are less likely to be grouped in the split files
        process_test_lists = Array.new(parallel_count) { [] }

        test_list.each_with_index do |test, index|
          process_test_lists[index % parallel_count] << test
        end

        process_test_lists.each_with_index do |process_test_list, index|
          directory = "#{REPORT_FOLDER}/#{test_type}/part_#{index + 1}"
          file_path = "test_list_#{index + 1}.txt"
          FileUtils.mkpath(directory)
          File.write("#{directory}/#{file_path}", process_test_list.join("\n"))
        end
      end

      # It's readable enough
      # rubocop:disable Metrics/MethodLength
      def generate_processes(parallel_count, test_type)
        [].tap do |processes|
          parallel_count.times do |process_count|
            directory        = "#{REPORT_FOLDER}/#{test_type}/part_#{process_count + 1}"
            stdout_file_name = "std_out_#{process_count + 1}.txt"
            stdout_file_path = "#{directory}/#{stdout_file_name}"

            process = if test_type == 'rspec'
                        create_parallel_rspec_process(process_count, directory)
                      else
                        create_parallel_cucumber_process(process_count, directory)
                      end

            FileUtils.touch(stdout_file_path)
            process.io.stdout                                         = File.new(stdout_file_path, 'w')
            process.environment['CUKE_LINTER_PARALLEL_PROCESS_COUNT'] = process_count + 1
            process.environment['CUKE_LINTER_TEST_PROCESS']           = 'true'
            process.start
            processes << process
          end
        end
      end

      # rubocop:enable Metrics/MethodLength

      def create_parallel_rspec_process(process_count, directory)
        json_file_path = "results_#{process_count + 1}.json"
        html_file_path = "results_#{process_count + 1}.html"

        create_process('bundle', 'exec', 'rspec',
                       '-r', './environments/rspec_env.rb',
                       '--format', 'RSpec::Core::Formatters::JsonFormatter', '--out', "#{directory}/#{json_file_path}", # rubocop:disable Metrics/LineLength
                       '--format', 'html', '--out', "#{directory}/#{html_file_path}",
                       '--format', 'p')
      end

      def create_parallel_cucumber_process(process_count, directory)
        json_file_path = "results_#{process_count + 1}.json"
        html_file_path = "results_#{process_count + 1}.html"

        create_process('bundle', 'exec', 'cucumber',
                       "@#{directory}/test_list_#{process_count + 1}.txt",
                       '-p', 'parallel',
                       '--format', 'json', '--out', "#{directory}/#{json_file_path}",
                       '--format', 'html', '--out', "#{directory}/#{html_file_path}",
                       '--format', 'progress')
      end

      def display_problems(problem_process_groups, test_type)
        puts Rainbow('Dumping output for errored processes...').yellow

        problem_process_groups.each do |process_number|
          puts Rainbow("Dumping output for process #{process_number}...").yellow

          directory        = "#{REPORT_FOLDER}/#{test_type}/part_#{process_number}"
          stdout_file_name = "std_out_#{process_number}.txt"
          stdout_file_path = "#{directory}/#{stdout_file_name}"

          process_output = File.read(stdout_file_path)
          puts Rainbow(process_output).cyan
        end
      end

    end

    extend Methods

  end
end
