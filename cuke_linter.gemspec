lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cuke_linter/version'

Gem::Specification.new do |spec|
  spec.name          = 'cuke_linter'
  spec.version       = CukeLinter::VERSION
  spec.authors       = ['Eric Kessler']
  spec.email         = ['morrow748@gmail.com']

  spec.summary       = 'Lints feature files used by Cucumber and other similar frameworks.'
  spec.description   = ["This gem provides linters for detecting common 'smells' in `.feature` files. ",
                        'In addition to the provided linters, custom linters can be made in order to ',
                        'create custom linting rules.'].join
  spec.homepage      = 'https://github.com/enkessler/cuke_linter'
  spec.license       = 'MIT'

  spec.metadata = {
    'bug_tracker_uri'       => 'https://github.com/enkessler/cuke_linter/issues',
    'changelog_uri'         => 'https://github.com/enkessler/cuke_linter/blob/master/CHANGELOG.md',
    'documentation_uri'     => 'https://www.rubydoc.info/gems/cuke_linter',
    'source_code_uri'       => 'https://github.com/enkessler/cuke_linter',
    'rubygems_mfa_required' => 'true'
  }


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('', __dir__)) do
    source_controlled_files = `git ls-files -z`.split("\x0")
    source_controlled_files.keep_if { |file| file =~ %r{^(lib|exe|testing/cucumber/features)} }
    source_controlled_files + ['README.md', 'LICENSE.txt', 'CHANGELOG.md', 'cuke_linter.gemspec']
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1', '< 4.0'

  spec.add_runtime_dependency 'cuke_modeler', '>= 1.5', '< 4.0'

  spec.add_development_dependency 'bundler', '< 3.0'
  spec.add_development_dependency 'childprocess', '< 4.0'
  spec.add_development_dependency 'cucumber', '< 5.0'
  spec.add_development_dependency 'cuke_slicer', '>= 2.0.2', '< 3.0'
  spec.add_development_dependency 'ffi', '~> 1.0'
  spec.add_development_dependency 'parallel', '~> 1.0'
  spec.add_development_dependency 'rainbow', '< 4.0.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'require_all', '~> 2.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  # Running recent RuboCop versions requires a recent version of Ruby but it can still lint against Ruby 2.1 styles.
  # Can't set a lower bound because RuboCop will still get installed in the testing environments for earlier Rubies,
  # even if it never actually gets run.
  spec.add_development_dependency 'rubocop', '< 2.0'
  spec.add_development_dependency 'simplecov', '< 1.0'
  spec.add_development_dependency 'simplecov-lcov', '< 1.0'
  spec.add_development_dependency 'yard', '< 1.0'
end
