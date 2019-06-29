Feature: Test with too many steps linter

  As a reader of documentation
  I want scenarios and outlines to not have an excessive number of steps
  So that I can fit it all in my head at once


  Scenario: Linting

  Note: Also works on outlines

    Given a linter for tests with too many steps
    And the following feature:
      """
      Feature:

        Scenario:
          * step 1
          * step 2
          * step 3
          * step 4
          * step 5
          * step 6
          * step 7
          * step 8
          * step 9
          * step 10
          * step one too many...
      """
    When it is linted
    Then an error is reported:
      | linter                     | problem                                          | location         |
      | TestWithTooManyStepsLinter | Test has too many steps. 11 steps found (max 10) | <path_to_file>:3 |

  Scenario: Configuration of step count threshold
    Given a linter for tests with too many steps has been registered
    And the following configuration file:
      """
      TestWithTooManyStepsLinter:
        StepThreshold: 3
      """
    And the following feature:
      """
      Feature:

        Scenario:
          * step 1
          * step 2
          * step 3
          * step one too many...
      """
    When the configuration file is loaded
    And the feature is linted
    Then an error is reported:
      | linter                     | problem                                        | location         |
      | TestWithTooManyStepsLinter | Test has too many steps. 4 steps found (max 3) | <path_to_file>:3 |
