Feature: Test with no name linter

  As a reader of documentation
  I want every scenario to have a name
  So that I can understand the significance of the use case


  Scenario: Linting

  Note: Also works on outlines.

    Given a linter for tests with no name
    And the following feature:
      """
      Feature:

        Scenario:
          This scenario has no name
      """
    When it is linted
    Then an error is reported:
      | linter               | problem                    | location         |
      | TestWithNoNameLinter | Test does not have a name. | <path_to_file>:3 |
