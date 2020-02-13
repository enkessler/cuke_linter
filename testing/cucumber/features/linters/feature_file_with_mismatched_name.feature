Feature: Feature file with mismatched name linter

  As a reader of documentation
  I want file names to match their features
  so that I can tell what a file is about by reading the name

  Scenario: Linting files with mismatched names
    Given a feature file model based on the file "some_name" with the following text:
    """
    Feature: Some different name
    """
    And a linter for features with mismatched file names
    When it is linted
    Then an error is reported:
      | linter                              | problem                                        | location       |
      | FeatureFileWithMismatchedNameLinter | Feature file name does not match feature name. | <path_to_file> |

  Scenario Outline: Linting files with matching names
    Given a feature file model based on the file "<file name>" with the following text:
    """
    Feature: <feature name>
    """
    And a linter for features with mismatched file names
    When it is linted
    Then no error is reported

    Examples:
      | file name             | feature name          |
      | name_with_underscores | Name with_underscores |
      | name with spaces      | Name with spaces      |
      | NameWithCaps          | Name with Caps        |
      | name-with-hyphens     | Name with-hyphens     |
