Feature: Scenario name with too many characters

  As a reader of documentation
  I want test names not to be unduly long
  So that I can easily understand its purpose


  Scenario: Linter

    Given a linter for test names with too many characters
    And the following feature:
      """
      Feature:

        Scenario: tea exists and teapots exist and so do cups and saucers and there might be milk in the milk jug together with sugar cubes
      """
    When it is linted
    Then an error is reported:
      | linter                              | problem                                                  | location         |
      | TestNameWithTooManyCharactersLinter | Scenario name is too long. 121 characters found (max 80) | <path_to_file>:3 |


  Scenario: Configuration of test name count threshold

    Given a linter for test names with too many characters has been registered
    And the following configuration file:
      """
      TestNameWithTooManyCharactersLinter:
        TestNameLengthThreshold: 30
      """
    And the following feature:
      """
      Feature:

        Scenario: This scenario name is way too long so it would be better to shorten it somehow, please do so
      """
    When the configuration file is loaded
    And the feature is linted
    Then an error is reported:
      | linter                              | problem                                                 | location         |
      | TestNameWithTooManyCharactersLinter | Scenario name is too long. 92 characters found (max 30) | <path_to_file>:3 |
