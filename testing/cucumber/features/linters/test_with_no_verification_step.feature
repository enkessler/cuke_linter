Feature: Test with no verification step linter

  As a tester
  I want tests to have at least one verification step
  So that I know that something is being checked


  Scenario: Linting

  Note: Also works on outlines. Also includes steps inherited from backgrounds.

    Given a linter for tests with no verification step
    And the following feature:
      """
      Feature:

        Scenario:
          Given some setup step
          When an action is taken
          And that's the end of the test
      """
    When it is linted
    Then an error is reported:
      | linter                           | problem                           | location         |
      | TestWithNoVerificationStepLinter | Test does not have a 'Then' step. | <path_to_file>:3 |

  Scenario: Configuration of keywords for different dialect
    Given a linter for tests with no verification step has been registered
    And the following configuration file:
      """
      TestWithNoVerificationStepLinter:
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
          Quando this is an action in pt dialect
          E this is and AND in pt dialect
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                           | problem                           | location         |
      | TestWithNoVerificationStepLinter | Test does not have a 'Then' step. | <path_to_file>:4 |

  @wip
  Scenario: Configuration

  Ideas: Configure whether or not the linter triggers on tests with no steps at all?
