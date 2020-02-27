Feature: Test with action step as final step linter

  As a tester
  I want to be warned about abnormal step flows
  So that the tests make sense


  Scenario: Linting

  Note: Also works on outlines.

    Given a linter for tests with an action step as the final step
    And the following feature:
      """
      Feature:

        Scenario: Action as final step
          When the last step
      """
    When it is linted
    Then an error is reported:
      | linter                              | problem                            | location         |
      | TestWithActionStepAsFinalStepLinter | Test has 'When' as the final step. | <path_to_file>:3 |

  Scenario: Configuration of keywords for different dialect
    Given a linter for tests with an action step as the final step has been registered
    And the following configuration file:
      """
      TestWithActionStepAsFinalStepLinter:
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
          Quando this is an action in pt dialect
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                              | problem                            | location         |
      | TestWithActionStepAsFinalStepLinter | Test has 'When' as the final step. | <path_to_file>:4 |