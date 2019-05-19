Feature: Feature without description linter

  As a writer of documentation
  I want features to have a description
  So that I do not have incomplete documentation


  Scenario: Linting
    Given a linter for features without a description
    And the following feature:
      """
      Feature: Features must have a description
      """
    When it is linted
    Then an error is reported
      | linter                          | problem                    | location         |
      | FeatureWithoutDescriptionLinter | Feature has no description | <path_to_file>:1 |
