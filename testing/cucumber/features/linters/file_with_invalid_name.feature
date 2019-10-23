Feature: File with invalid name linter

  As a writer of documentation
  I want to be warned about invalid file name
  so that I name all features consistently

  Scenario: Linting
    Given a file named "<name>.feature" with:
      """
      Feature:
      """
    When it is linted
    Then an error is reported:
      | linter                    | problem                              | location         |
      | FileWithInvalidNameLinter | Feature files should be snake_cased. | <path_to_file>:3 |

    Examples: Invalid Names
      | name    |
      | Lint    |
      | lintMe  |
      | lint me |
      | lint-me |
