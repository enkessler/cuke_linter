Feature: Test with setup step after verification step linter

  As a tester
  I want to be warned about abnormal step flows
  So that the tests make sense


  Scenario: Linting

  Note: Also works on outlines. Does not include steps inherited from backgrounds.

    Given a linter for tests with a setup step after a verification step
    And the following feature:
      """
      Feature:

        Scenario:
          Then verification step
          Given an out of place setup step
      """
    When it is linted
    Then an error is reported:
      | linter                                       | problem                                  | location         |
      | TestWithSetupStepAfterVerificationStepLinter | Test has 'Given' step after 'Then' step. | <path_to_file>:3 |

  @wip
  Scenario: Configuration

  Configure the keyword(s) that count as verification steps?
  Configure whether or not to include background steps?
