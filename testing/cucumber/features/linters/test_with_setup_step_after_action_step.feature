Feature: Test with setup step after action step linter

  As a tester
  I want to be warned about abnormal step flows
  So that the tests make sense


  Scenario: Linting

  Note: Also works on outlines. Does not include steps inherited from backgrounds.

    Given a linter for tests with a setup step after an action step
    And the following feature:
      """
      Feature:

        Scenario:
          When action step
          Given an out of place setup step
      """
    When it is linted
    Then an error is reported:
      | linter                                 | problem                                  | location         |
      | TestWithSetupStepAfterActionStepLinter | Test has 'Given' step after 'When' step. | <path_to_file>:3 |

  @wip
  Scenario: Configuration

  Configure the keyword(s) that count as setup/action/verification steps?
  Configure whether or not to include background steps?
