Feature: Feature without name linter

  As a reader of documentation
  I want every feature to have a name
  So that I can get an idea of  what the feature is about without having to read every use case


  Scenario: Linting
    Given a linter for features without a name
    And the following feature:
      """
      Feature:
        This feature does not have a name
      """
    When it is linted
    Then an error is reported:
      | linter                   | problem                       | location         |
      | FeatureWithoutNameLinter | Feature does not have a name. | <path_to_file>:1 |
