namespace 'cuke_linter' do

  desc 'Removes the current code coverage data'
  task :clear_coverage do
    puts Rainbow('Clearing base coverage directory...').cyan
    code_coverage_directory = "#{__dir__}/../coverage"

    FileUtils.remove_dir(code_coverage_directory, true)
  end

  desc 'Combines the various code coverage reports into one'
  task :combine_code_coverage_reports do
    puts Rainbow('Combining code coverage reports...').cyan
    CukeLinter::ParallelHelper.combine_code_coverage_reports
  end

  desc 'Removes the contents of the test reporting directory'
  task :clear_report_directory do
    puts Rainbow('Clearing report directory...').cyan

    FileUtils.remove_dir(CukeLinter::ParallelHelper::REPORT_FOLDER, true)
    FileUtils.mkdir(CukeLinter::ParallelHelper::REPORT_FOLDER)
  end

  desc 'Removes existing test results and code coverage'
  task :clear_old_results => %i[clear_report_directory clear_coverage] # rubocop:disable Style/HashSyntax

end
