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

  Scenario: Configuration of keywords for different dialect
    Given a linter for tests with a setup step after a verification step has been registered
    And the following configuration file:
      """
      TestWithSetupStepAfterVerificationStepLinter:
        Given:
          - Dado
        When:
          - Quando
        Then:
          - Então
      """
    And the following feature:
      """
      # language:pt
      Funcionalidade: Feature name

        Cenário: scenario name
          Então this is an validation in pt dialect
          Dado some setup in pt dialect
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                                       | problem                                  | location         |
      | TestWithSetupStepAfterVerificationStepLinter | Test has 'Given' step after 'Then' step. | <path_to_file>:4 |

  @wip
  Scenario: Configuration

  Configure whether or not to include background steps?
