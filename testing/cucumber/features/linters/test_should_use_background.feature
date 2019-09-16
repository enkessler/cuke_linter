Feature: Test should use background linter

  As a writer of documentation
  I want to know if I am including the same steps in every use case
  So that I can use a background to make it clear that a common context exists


  Scenario: Linting

  Note: Also works on outlines.

    Given a linter for tests that should use a background
    And the following feature:
      """
      Feature:

        Scenario:
          * a common step
          * a different step

        Scenario:
          * a common step
          * a more different step
      """
    When it is linted
    Then an error is reported:
      | linter                        | problem                                                              | location         |
      | TestShouldUseBackgroundLinter | Test shares steps with all other tests in feature. Use a background. | <path_to_file>:3 |
      | TestShouldUseBackgroundLinter | Test shares steps with all other tests in feature. Use a background. | <path_to_file>:7 |
