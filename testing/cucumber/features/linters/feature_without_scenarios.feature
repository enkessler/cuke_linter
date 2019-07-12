Feature: Feature without scenarios linter

  As a writer of documentation
  I want features to have at least one use case
  So that I do not have incomplete documentation


  Scenario: Linting
    Given a linter for features without scenarios
    And the following feature:
      """
      Feature:
      """
    When it is linted
    Then an error is reported:
      | linter                        | problem                  | location         |
      | FeatureWithoutScenariosLinter | Feature has no scenarios | <path_to_file>:1 |
