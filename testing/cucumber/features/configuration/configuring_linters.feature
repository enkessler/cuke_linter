Feature: Configuration of linters

  Instead of having to modify the linting object directly in a script at runtime, a configuration file can be used so that specific linters can be configured in a more convenient, static manner. Some configurable properties are available across all linters while some are linter specific.


  Scenario: Disabling a linter
    Given a linter registered as "AlwaysFindsAProblem"
    And the following configuration file:
      """
      AlwaysFindsAProblem:
        Enabled: false
      """
    And the following feature:
      """
      Feature: Something in which a problem could exist
      """
    When the configuration file is used
    And the feature is linted
    Then no error is reported
