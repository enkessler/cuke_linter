source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in cuke_linter.gemspec
gemspec


cuke_modeler_major_version = 3

case cuke_modeler_major_version
  when 1, 2
    # Newer versions of Cucumber won't work with older versions of `cuke_modeler` due to trying to
    # use `gherkin` and `cucumber-gherkin` at the same time
    gem 'cucumber', '2.2.0'
  else
    gem 'cucumber', '>= 4.0'
end

gem 'cuke_modeler', "~> #{cuke_modeler_major_version}.0"
