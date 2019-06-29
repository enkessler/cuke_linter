Feature: Test step with too many characters

  As a reader of documentation
  I want test steps not to be unduly long
  So that I can easily understand its purpose


  Scenario: Linting

    Given a linter for test steps with too many characters
    And the following feature:
      """
      Feature:

        Scenario:
          * tea exists and teapots exist and so do cups and saucers and there might be milk in the milk jug together with sugar cubes
      """
    When it is linted
    Then an error is reported:
      | linter                          | problem                                         | location         |
      | StepWithTooManyCharactersLinter | Step is too long. 121 characters found (max 80) | <path_to_file>:4 |


  Scenario: Configuration of step count threshold

    Given a linter for test steps with too many characters has been registered
    And the following configuration file:
      """
      StepWithTooManyCharactersLinter:
        StepLengthThreshold: 55
      """
    And the following feature:
      """
      Feature:

        Scenario:
          Given that a rose by any other name would still smell as sweet
      """
    When the configuration file is loaded
    And the feature is linted
    Then an error is reported:
      | linter                          | problem                                        | location         |
      | StepWithTooManyCharactersLinter | Step is too long. 56 characters found (max 55) | <path_to_file>:4 |
