
Feature: Tests with bad names are reported

  As a writer of documentation
  I want to be warned about assertion style scenario names
  So that I will be able to understand the intent

  Scenario Outline: Flag a test with a bad name

    Note: Also works on outlines.

    Given a linter for tests with bad names
    And the following feature:
      """
      Feature: Bad scenario names

        Scenario: <example_word> scenario name
          This scenario uses a bad name
      """
    When it is linted
    Then an error is reported:
      | linter                | problem                                                            | location         |
      | TestWithBadNameLinter | "Test", "Verify" and "Check" should not be used in scenario names. | <path_to_file>:3 |

  Examples:
    | example_word |
    | test         |
    | verify       |
    | check        |
