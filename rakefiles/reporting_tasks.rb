namespace 'cuke_linter' do

  desc 'Combines the various code coverage reports into one'
  task :combine_code_coverage_reports do
    puts Rainbow('Combining code coverage reports...').cyan
    CukeLinter::ParallelHelper.combine_code_coverage_reports
  end

  desc 'Removes the contents of the test reporting directory'
  task :clear_report_directory do
    puts Rainbow('Clearing report directory...').cyan

    FileUtils.remove_dir(ENV.fetch('CUKE_LINTER_REPORT_FOLDER'), true)
    FileUtils.mkdir(ENV.fetch('CUKE_LINTER_REPORT_FOLDER'))
  end

  desc 'Removes existing test results and code coverage'
  task :clear_old_results => %i[clear_report_directory] # rubocop:disable Style/HashSyntax

end
