# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake cuke_linter:test_everything` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/enkessler/cuke_linter.

1. Fork it
2. Create your feature branch **(off of the development branch)**
   `git checkout -b my-new-feature dev`
3. Commit your changes
   `git commit -am 'Add some feature'`
4. Push to the branch
   `git push origin my-new-feature`
5. Create new Pull Request


### Adding a new linter

Some guidelines when adding a new linter
  * Inherit from the base linter class. It will handle almost all of the functional requirements of a linter.
  * Existing linters should provide decent examples of how to create new linters and how to test them. A copy/paste/tweak approach is perfectly valid.
  * Keep linters simple. Rather than have one linter that has different behaviors depending on context, create a different linter class for each context.
  * Keep things alphabetical. There are going to be lots of linters and things will be easier to find if lists of them in the code base (e.g. `require` statments, documentation, etc.) are in an intuitive order.
