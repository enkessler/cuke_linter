require 'rake'
require "bundler/gem_tasks"
require 'racatt'


namespace 'racatt' do
  Racatt.create_tasks
end

namespace 'cuke_linter' do

  desc 'Run all of the tests'
  task :test_everything do
    rspec_args = '--pattern testing/rspec/spec/**/*_spec.rb'
    cucumber_args = "testing/cucumber/features -r environments/cucumber_env.rb -f progress -t 'not @wip'"

    Rake::Task['racatt:test_everything'].invoke(rspec_args, cucumber_args)
  end

end


task :default => 'cuke_linter:test_everything'
