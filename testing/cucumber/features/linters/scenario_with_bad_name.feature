Feature: Scenario with bad name linter

  As a reader of documentation
  I want every scenario to have Given and When steps rather than Test, Verify or Check
  So that the naming is consistent and intent clear


  Scenario: Linting

  Note: Also works on outlines.

    Given a linter for tests with bad names
    And the following feature:
      """
      Feature:

        Scenario:
          This scenario has a bad name
      """
    When it is linted
    Then an error is reported:
      | linter                    | problem                                                                                      | location         |
      | ScenarioWithBadNameLinter | Prefer name your scenarios using "Given" and "When" rather than "test", "verify" or "check". | <path_to_file>:3 |
