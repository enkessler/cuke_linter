Feature: Outline with single example row linter

  As a writer of documentation
  I want outlines to have at least two example rows
  So that I am not needlessly using an outline instead of a scenario


  Scenario: Linting
    Given a linter for outlines with only one example row
    And the following feature:
      """
      Feature:

        Scenario Outline:
          * a step
        Examples:
          | param |
          | value |
      """
    When it is linted
    Then an error is reported:
      | linter                            | problem                          | location         |
      | OutlineWithSingleExampleRowLinter | Outline has only one example row | <path_to_file>:3 |
