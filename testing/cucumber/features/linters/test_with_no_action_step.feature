Feature: Test with no action step linter

  As a tester
  I want tests to have at least one action step
  So that I know what is triggering the behavior that is being checked


  Scenario: Linting

  Note: Also works on outlines. Also includes steps inherited from backgrounds.

    Given a linter for tests with no action step
    And the following feature:
      """
      Feature:

        Scenario:
          Given some setup step
          Then that's the end of the test
      """
    When it is linted
    Then an error is reported:
      | linter                     | problem                           | location         |
      | TestWithNoActionStepLinter | Test does not have a 'When' step. | <path_to_file>:3 |

  Scenario: Configuration of keywords for different dialect
    Given a linter for tests with no action step has been registered
    And the following configuration file:
      """
      TestWithNoActionStepLinter:
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
          Então this is an validation in pt dialect
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                     | problem                           | location         |
      | TestWithNoActionStepLinter | Test does not have a 'When' step. | <path_to_file>:4 |

  @wip
  Scenario: Configuration

  Ideas: Configure whether or not the linter triggers on tests with no steps at all?
