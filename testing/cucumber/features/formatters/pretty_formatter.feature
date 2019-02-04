Feature: Pretty formatter

  Scenario: Formatting linter data
    Given the following linter data:
      | linter name     | problem             | location             |
      | SomeLinter      | Some problem        | path/to/the_file:1   |
      | SomeOtherLinter | Some other problem  | path/to/the_file:33  |
      | SomeOtherLinter | Some other problem  | path/to/the_file:101 |
      | SomeOtherLinter | Yet another problem | path/to/the_file:55  |
    When it is formatted by the "pretty" formatter
    Then the resulting output is the following:
      """
      SomeLinter
        Some problem
          path/to/the_file:1
      SomeOtherLinter
        Some other problem
          path/to/the_file:33
          path/to/the_file:101
        Yet another problem
          path/to/the_file:55

      4 issues found
      """
