Feature: Step that ends with a period linter

  As a writer of documentation
  I want to avoid periods at the end of steps
  So that readability is not impacted when they are used elsewhere


  Scenario: Linting
    Given a linter for steps the end with a period
    And the following feature:
      """
      Feature:

        Scenario:
          * an okay step
          * a bad step.
      """
    When it is linted
    Then an error is reported:
      | linter                  | problem                 | location         |
      | StepWithEndPeriodLinter | Step ends with a period | <path_to_file>:5 |
