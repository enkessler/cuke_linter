Feature: Unique scenario names

  As a reader of documentation
  I want each scenario to have a unique name within its scope, where scenarios in Rules are scoped to their Rule and other scenarios are scoped to the Feature file
  So that each scenario clearly describes a specific aspect of the application's functionality.

  Scenario: Linting (Good: No Duplicates within Feature including Rules)
    Given the following feature:
      """
      Feature: Sample Feature

        Scenario: Unique Scenario Name 1
          Given something

        Scenario: Unique Scenario Name 2
          Given something else

        Scenario Outline: Unique Scenario Outline Name With <input>
        Examples:
          | input          |
          | something      |
          | something else |

        Rule: Example Rule
          Scenario: Unique Scenario Name within Rule 1
            Given a rule specific condition

          Scenario: Unique Scenario Name within Rule 2
            Given another rule specific condition

          Scenario: Unique Scenario Name 1
            Given something

        Rule: Example Rule 1
          Scenario: Duplicate Scenario Name
            Given something

        Rule: Example Rule 2
          Scenario: Duplicate Scenario Name
            Given something
      """
    And a linter for unique scenario names
    When the model is linted
    Then no error is reported

  Scenario: Linting (Good: Duplicates within different Rules)
    Given the following feature:
      """
      Feature: Sample Feature with Rules

        Rule: Sample Rule 1

          Scenario: Duplicate Scenario Name
            Given something

        Rule: Sample Rule 2

          Scenario: Duplicate Scenario Name
            Given something
      """
    And a linter for unique scenario names
    When the model is linted
    Then no error is reported

  Scenario: Linting (Good: Duplicates within Rule and regular scenario)
    Given the following feature:
      """
      Feature: Sample Feature with Rules

        Scenario: Duplicate Scenario Name
          Given something

        Rule: Sample Rule

          Scenario: Duplicate Scenario Name
            Given something
      """
    And a linter for unique scenario names
    When the model is linted
    Then no error is reported

  Scenario: Linting (Bad: Duplicates of regular scenario name and one from a Rule)
    Given the following feature:
      """
      Feature: Sample Feature

        Rule: Example Rule
          Scenario: Duplicate Scenario Name
            Given something

        Scenario: Duplicate Scenario Name
          Given something
      """
    And a linter for unique scenario names
    When the model is linted
    Then the following problems are reported:
      | linter                     | problem                                                                                                         | location        |
      | UniqueScenarioNamesLinter  | Scenario name 'Duplicate Scenario Name' is not unique.\n    Original name is on line: 4\n    Duplicate is on: 7 | path_to_file:3  |

  Scenario: Linting (Bad: Duplicates within Feature)
    Given the following feature:
      """
      Feature: Sample Feature

        Scenario: Duplicate Scenario Name
          Given something

        Scenario: Duplicate Scenario Name
          Given something else
      """
    And a linter for unique scenario names
    When the model is linted
    Then the following problems are reported:
      | linter                     | problem                                                                                                         | location        |
      | UniqueScenarioNamesLinter  | Scenario name 'Duplicate Scenario Name' is not unique.\n    Original name is on line: 3\n    Duplicate is on: 6 | path_to_file:6  |

  Scenario: Linting (Bad: Duplicates from Scenario Outline)
    Given the following feature:
      """
      Feature: Sample Feature with Scenario Outline

        Scenario Outline: Duplicate Scenario Name With <input>

        Examples:
          | input     |
          | something |
          | something |
      """
    And a linter for unique scenario names
    When the model is linted
    Then the following problems are reported:
      | linter                     | problem                                                                                                                                                    | location        |
      | UniqueScenarioNamesLinter  | Scenario name created by Scenario Outline 'Duplicate Scenario Name With something' is not unique.\n    Original name is on line: 3\n    Duplicate is on: 3 | path_to_file:3  |

  Scenario: Linting (Bad: Duplicates within Rule)
    Given the following feature:
      """
      Feature: Sample Feature with Rules

        Rule: Sample Rule

          Scenario: Duplicate Scenario Name
            Given something

          Scenario: Duplicate Scenario Name
            Given something else
      """
    And a linter for unique scenario names
    When the model is linted
    Then the following problems are reported:
      | linter                     | problem                                                                                                         | location        |
      | UniqueScenarioNamesLinter  | Scenario name 'Duplicate Scenario Name' is not unique.\n    Original name is on line: 5\n    Duplicate is on: 8 | path_to_file:3  |

  Scenario: Linting (Bad: Duplicates from Scenario Outline without placeholders)
    Given the following feature:
      """
      Feature: Sample Feature with Scenario Outline without placeholders

        Scenario Outline: Duplicate Scenario Name

        Examples:
          | input          |
          | Something      |
          | Something else  |
      """
    And a linter for unique scenario names
    When the model is linted
    Then the following problems are reported:
      | linter                    | problem                                                                                                                                     | location        |
      | UniqueScenarioNamesLinter | Scenario name created by Scenario Outline 'Duplicate Scenario Name' is not unique.\n    Original name is on line: 3\n    Duplicate is on: 3 | path_to_file:3  |

  Scenario: Linting (Bad: No Scenario Name with Different Examples)
    Given the following feature:
      """
      Feature: Sample Feature with Scenario Outline without a Name

        Scenario Outline:
          Given I have <input>

        Examples:
          | input     |
          | something |
          | anything  |
      """
    And a linter for unique scenario names
    When the model is linted
    Then the following problems are reported:
      | linter                     | problem                                                                                                              | location        |
      | UniqueScenarioNamesLinter  | Scenario name created by Scenario Outline '' is not unique.\n    Original name is on line: 3\n    Duplicate is on: 3 | path_to_file:3  |
