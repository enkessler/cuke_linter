Feature: Example without name linter

  Scenario: Linting
    Given a linter for examples without names
    And the following feature:
      """
      Feature:

        Scenario Outline:
          * a step
        Examples:
          | param |
          | value |
        Examples:
          | param |
          | value |
      """
    When it is linted
    Then an error is reported
      | linter                   | problem             | location         |
      | ExampleWithoutNameLinter | Example has no name | <path_to_file>:5 |
      | ExampleWithoutNameLinter | Example has no name | <path_to_file>:8 |
