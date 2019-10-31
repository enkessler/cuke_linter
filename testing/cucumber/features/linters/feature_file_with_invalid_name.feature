Feature: Feature file with invalid name linter

  As a writer of documentation
  I want to be warned about invalid file names
  so that I name all features consistently

  Scenario Outline: Linting
    Given a feature file model named "<name>.feature"
    And a linter for features with invalid file names
    When it is linted
    Then an error is reported:
      | linter                           | problem                              | location       |
      | FeatureFileWithInvalidNameLinter | Feature files should be snake_cased. | <path_to_file> |

    Examples: Invalid Names
      | name    |
      | Lint    |
      | lintMe  |
      | lint me |
      | lint-me |
