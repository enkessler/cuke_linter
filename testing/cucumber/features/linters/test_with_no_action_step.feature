Feature: Test with no action step linter

  As a tester
  I want tests to have at least one action step
  So that I know what is triggering the behavior that is being checked


  Scenario: Linting

  Note: Also works on outlines

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

  @wip
  Scenario: Configuration

  Ideas: Configure whether or not the linter triggers on tests with no steps at all?
  Configure the keyword(s) that count as an action step?
