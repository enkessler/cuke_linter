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

  Scenario: Configuration of keywords for different dialect
    Given a linter for tests with a setup step as the final step has been registered
    And the following configuration file:
      """
      TestWithSetupStepAsFinalStepLinter:
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
          Dado some setup in pt dialect
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                             | problem                             | location         |
      | TestWithSetupStepAsFinalStepLinter | Test has 'Given' as the final step. | <path_to_file>:4 |
