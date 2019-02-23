Feature: Feature without scenarios linter

  Scenario: Linting
    Given a linter for features without scenarios
    And the following feature:
      """
      Feature:
      """
    When it is linted
    Then an error is reported
      | linter                        | problem                  | location         |
      | FeatureWithoutScenariosLinter | Feature has no scenarios | <path_to_file>:1 |
