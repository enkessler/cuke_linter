Feature: Unique scenario names linter

  As a tester
  I want each scenario to have a unique name even though they were created using a template.
  So that I can easily identify and refer to them without confusion

  Scenario: Detect scenarios with duplicate names within the same feature file
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
      | linter                     | problem                             | location             |
      | UniqueScenarioNamesLinter  | Scenario names are not unique       | path_to_file:6       |

  Scenario: Detect unique scenario names within the same feature file
    Given the following feature:
      """
      Feature: Sample Feature

        Scenario: Unique Scenario Name 1
          Given something

        Scenario: Unique Scenario Name 2
          Given something else
      """
    And a linter for unique scenario names
    When the model is linted
    Then no error is reported

  Scenario: Detect duplicated scenario names generated from a scenario outline
    Given the following feature:
      """
      Feature: Sample Feature with Scenario Outline

        Scenario Outline: Duplicate Scenario Name With <input>

        Examples:
          | input         |
          | something     |
          | something     |
      """
    And a linter for unique scenario names
    When the model is linted
    Then the following problems are reported:
      | linter                     | problem                                             | location        |
      | UniqueScenarioNamesLinter  | Template creates scenario names that are not unique | path_to_file:3  |

  Scenario: Detect unique scenario names generated from a scenario outline
    Given the following feature:
      """
      Feature: Sample Feature with Scenario Outline

        Scenario Outline: Unique Scenario Names With <input>

        Examples:
          | input          |
          | something      |
          | something else |
      """
    And a linter for unique scenario names
    When the model is linted
    Then no error is reported
