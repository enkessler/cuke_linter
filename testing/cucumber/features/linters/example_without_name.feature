Feature: Example without name linter

  As a reader of documentation
  I want every example to have a name
  So that I can understand the significance of the example grouping


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
    Then an error is reported:
      | linter                   | problem             | location         |
      | ExampleWithoutNameLinter | Example has no name | <path_to_file>:5 |
      | ExampleWithoutNameLinter | Example has no name | <path_to_file>:8 |

  @wip
  Scenario: Configuration

  Ideas: Configure whether or not the linter triggers on outline with only one Example set?
