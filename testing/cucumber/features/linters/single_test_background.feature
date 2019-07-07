Feature: Single test background linter


  As a writer of documentation
  I want backgrounds to apply to at least two tests
  So that I am not needlessly using a background instead of adding the background steps directly to the test


  Scenario: Linting
    Given a linter for backgrounds applied to only one test
    And the following feature:
      """
      Feature:

        Background:
          * a step

        Scenario:
          * a step
      """
    When it is linted
    Then an error is reported:
      | linter                     | problem                            | location         |
      | SingleTestBackgroundLinter | Background used with only one test | <path_to_file>:3 |
