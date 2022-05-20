Feature: Feature without scenarios linter

  As a writer of documentation
  I want features to have at least one use case
  So that I do not have incomplete documentation


  Scenario: Linting (Bad)
    Given a linter for features without scenarios
    And the following feature:
      """
      Feature:
      """
    When it is linted
    Then an error is reported:
      | linter                        | problem                  | location         |
      | FeatureWithoutScenariosLinter | Feature has no scenarios | <path_to_file>:1 |

  Scenario: Linting (Good)
    Given a linter for features without scenarios
    And the following feature:
      """
      Feature:
        Scenario:
      """
    When it is linted
    Then no error is reported

  Scenario: Linting (Good, with Rules)
    Given a linter for features without scenarios
    And the following feature:
      """
      Feature:
        Rule:
          Scenario:
      """
    When it is linted
    Then no error is reported
