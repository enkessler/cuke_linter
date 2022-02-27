# Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Testing

`bundle exec rake cuke_linter:test_everything` will run all of the tests for the project. To run just the RSpec tests 
or Cucumber tests specifically:
 - `bundle exec rspec  --pattern "testing/rspec/spec/**/*_spec.rb"` or
   `bundle exec rake cuke_linter:run_rspec_tests` or
   `bundle exec rake cuke_linter:run_rspec_tests_in_parallel`

 - `bundle exec cucumber` or
   `bundle exec rake cuke_linter:run_cucumber_tests` or 
   `bundle exec rake cuke_linter:run_cucumber_tests_in_parallel`


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/enkessler/cuke_linter.

1. Fork it
2. Create your feature branch
   `git checkout -b my-new-feature`
3. Commit your changes
   `git commit -am 'Add some feature'`
4. Push to the branch
   `git push origin my-new-feature`
5. Create new Pull Request

Be sure to update the `CHANGELOG` to reflect your changes if they affect the outward behavior of the gem.

### Adding a new linter

Some guidelines when adding a new linter
  * Inherit from the base linter class. It will handle most of the boilerplate functional requirements of a linter.
  * Existing linters should provide decent examples of how to create new linters and how to test them. A copy/paste/tweak approach is perfectly valid.
  * Keep linters simple. Rather than have one linter that has different behaviors depending on context, create a different linter class for each context.
  * Keep things alphabetical. There are going to be lots of linters and things will be easier to find if lists of them in the code base (e.g. `require` statments, documentation, etc.) are in an intuitive order.
  * Because linters are based on models, name them after the model type that they lint. E.g. `FeatureThatHasAThing`, `OutlineWithoutThing`, etc.
  * DO NOT add the new linter to the default linters. The default linters will be updated when new major versions are released.

### Adding a new formatter

Some guidelines when adding a new formatter
  * While most linters only produce a single type of problem, it is not a strict requirement. The formatter should be able to handle multiple problem types per linter.
  * Some linters report problems at the file level instead of the line level. The formatter should be able to handle locations that do not include line numbers.
