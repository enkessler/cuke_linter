Feature: Test with setup step as final step linter

  As a tester
  I want to be warned about abnormal step flows
  So that the tests make sense


  Scenario: Linting

  Note: Also works on outlines.

    Given a linter for tests with a setup step as the final step
    And the following feature:
      """
      Feature:

        Scenario:
          Given the last step
      """
    When it is linted
    Then an error is reported:
      | linter                             | problem                             | location         |
      | TestWithSetupStepAsFinalStepLinter | Test has 'Given' as the final step. | <path_to_file>:3 |

  @wip
  Scenario: Configuration

  Configure the keyword(s) that count as setup steps?
  Configure whether or not to include background steps?
