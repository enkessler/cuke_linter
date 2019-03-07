require 'rake'
require 'racatt'
require 'coveralls/rake/task'


namespace 'racatt' do
  Racatt.create_tasks
end

namespace 'cuke_linter' do

  desc 'Removes the current code coverage data'
  task :clear_coverage do
    code_coverage_directory = "#{__dir__}/coverage"

    FileUtils.remove_dir(code_coverage_directory, true)
  end


  desc 'Run all of the tests'
  task :test_everything => [:clear_coverage] do
    test_files = Dir.glob('testing/rspec/spec/**{,/*/**}/*_spec.rb')
    puts "files matching pattern (#{test_files.count}): #{test_files}"
    rspec_args    = '--pattern testing/rspec/spec/**{,/*/**}/*_spec.rb -f d'
    cucumber_args = "testing/cucumber/features -r environments/cucumber_env.rb -f progress -t 'not @wip'"

    Rake::Task['racatt:test_everything'].invoke(rspec_args, cucumber_args)
  end

  # creates coveralls:push task
  Coveralls::RakeTask.new

  desc 'The task that CI will run. Do not run locally.'
  task :ci_build => ['cuke_linter:test_everything', 'coveralls:push']
end


task :default => 'cuke_linter:test_everything'
