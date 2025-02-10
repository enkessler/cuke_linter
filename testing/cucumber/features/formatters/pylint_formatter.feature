Feature: Pylint formatter

  The Pylint formatter is a formatter with a more easily machine-parseable output.

  Scenario: Formatting linter data
    Given the following linter data:
      | linter name                      | problem             | location               |
      | FeatureFileWithInvalidNameLinter | Invalid file name   | path/to/the-file       |
      | FeatureWithoutDescriptionLinter  | No description      | path/to/the_file:1     |
      | SomeOtherLinter                  | Some other problem  | path/to/the_file:33    |
      | SomeOtherLinter                  | Problem with column | path/to/the_file:33:33 |
    When it is formatted by the "Pylint" formatter
    Then the resulting output is the following:
      """
      path/to/the/file::: [FeatureFileWithInvalidNameLinter] Invalid file name
      path/to/the_file:1:: [FeatureWithoutDescriptionLinter] No description
      path/to/the_file:33:: [SomeOtherLinter] Some other problem
      path/to/the_file:33:33: [SomeOtherLinter] Problem with column
      """
