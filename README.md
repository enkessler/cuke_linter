Basic stuff:
[![Gem Version](https://badge.fury.io/rb/cuke_linter.svg)](https://rubygems.org/gems/cuke_linter)
[![Project License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/mit-license.php)
[![Downloads](https://img.shields.io/gem/dt/cuke_linter.svg)](https://rubygems.org/gems/cuke_linter)

User stuff:
[![Cucumber Docs](http://img.shields.io/badge/Documentation-Features-green.svg)](https://app.cucumber.pro/projects/cuke_linter)
[![Yard Docs](http://img.shields.io/badge/Documentation-API-blue.svg)](https://www.rubydoc.info/gems/cuke_linter)

Developer stuff:
[![Build Status](https://travis-ci.org/enkessler/cuke_linter.svg?branch=dev)](https://travis-ci.org/enkessler/cuke_linter)
[![Build Status](https://ci.appveyor.com/api/projects/status/g5o70u747x073evy/branch/dev?svg=true)](https://ci.appveyor.com/project/enkessler/cuke-linter/branch/dev)
[![Coverage Status](https://coveralls.io/repos/github/enkessler/cuke_linter/badge.svg?branch=dev)](https://coveralls.io/github/enkessler/cuke_linter?branch=dev)
[![Maintainability](https://api.codeclimate.com/v1/badges/d1b86760e59a457c8e73/maintainability)](https://codeclimate.com/github/enkessler/cuke_linter/maintainability)
[![Inline docs](http://inch-ci.org/github/enkessler/cuke_linter.svg?branch=dev)](https://inch-ci.org/github/enkessler/cuke_linter?branch=dev)

---

# CukeLinter

So you have started to use Cucumber to describe your system in the abstract, natural language style of Gherkin. But wait! All of your feature files are themselves code and that means that they may need the same protection from anti-patterns as the lower level source code of your system. Enter `cuke_linter`.

This gem provides linting functionality for `.feature` files by building upon the modeling capabilities of the [cuke_modeler](https://github.com/enkessler/cuke_modeler) gem. By passing models through a set of linters, reports can be generated that will inform you of potential bugs, style violations, or anything else that you can define as a problem  via custom linters! 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cuke_linter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cuke_linter

## Usage

#### From the command line

The easiest way to use the gem is to use all of the defaults by invoking it from the command line directly.

```
$ cuke_linter
```

Additional command line options can be provided that can adjust the default behavior. See [documentation](#documentation) for specifics.

#### From a Ruby script

The linter can also be used inside of a Ruby script, like so:

```
require 'cuke_linter'

CukeLinter.lint
```

The linting will happen against a tree of `CukeModeler` models that is generated based on the current directory. You can generate your own model trees and use them instead, if desired, or even provide specific file paths that will be modeled and linted.

`cuke_linter` comes with a set of pre-made linters and will use them by default but custom linters can be used instead. Custom linters can be any object that responds to `#lint` and returns a detected issue (or `nil`) in the format of

```
{ problem: 'some linting issue',
  location: 'path/to/file:line_number' }
```

Note that a linter will receive, in turn, *every model* in a model tree in order for it to have the chance to detect problems with it. Checking the model's class before attempting to lint it is recommended.

**In order to simplify the process of creating custom linters a base class is provided (see [documentation](#documentation)).**

`cuke_linter` comes with a set of pre-made formatters and will use them by default but custom formatters can be used instead. Custom formatters can be any object that responds to `#format` and takes input data in the following format:

```
[
 { linter: 'some linter name',
   problem: 'some linting issue',
   location: 'path/to/file:line_number' },
 { linter: 'some linter name',
   problem: 'some linting issue',
   location: 'path/to/file:line_number' },
   # etc.
]
```

All formatted data will be output to STDOUT unless a file location is provided as an alternative.

Below is an example of using non-default linting options.

```
require 'cuke_linter'

class MyCustomLinter

  def name
    'MyCustomLinter'
  end

  def lint(model)
    return nil unless model.is_a?(CukeModeler::Scenario)

    if model.name.empty?
      { problem: 'Scenario has no name', location: "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" }
    else
      nil
    end
  end

end

class MyCustomFormatter

  def format(linting_data)
    formatted_data = ''

    linting_data.each do |lint_item|
      formatted_data << "#{lint_item[:linter]}\n"
      formatted_data << "  #{lint_item[:problem]}\n"
      formatted_data << "    #{lint_item[:location]}\n"
    end

    formatted_data
  end

end

linter               = MyCustomLinter.new
formatter            = MyCustomFormatter.new
output_path          = "#{__dir__}/my_report.txt"
model_tree_root      = CukeModeler::Directory.new(Dir.pwd)
additional_file_path = 'path/to/some.feature'

# Providing the formatter twice so that it also is printed to the console
CukeLinter.lint(linters: [linter], formatters: [[formatter], [formatter, output_path]], model_trees: [model_tree_root], file_paths: [additional_file_path])
```

### Configuration

Rather than using the default linters or providing a custom set of of modified linters every time linting occurs, which linters to use and any linter specific modifications can be configured in a more static manner via a configuration file or setting the configuration directly in code. See [documentation](#documentation) for specifics.


### <a id="documentation"></a>Everything Else

For more detailed examples of usage, see the documentation [here](https://app.cucumber.pro/projects/cuke_linter).


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake cuke_linter:test_everything` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/enkessler/cuke_linter.

1. Fork it
2. Create your feature branch **(off of the development branch)**
   `git checkout -b my-new-feature`
3. Commit your changes
   `git commit -am 'Add some feature'`
4. Push to the branch
   `git push origin my-new-feature`
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
