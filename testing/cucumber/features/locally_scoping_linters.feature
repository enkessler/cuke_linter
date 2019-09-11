Feature: Locally scoping linters

  As a writer of documentation
  I want to be able to limit the scope of linters for certain portions of the documentation
  So that exceptions to rules can be made

  In addition to using configurations to change whether or not a given linter is used when linting, linters can be enabled/disabled for specific portions of a `.feature` file. To enable/disable one (or more) linters, add a comment line before the portion of the file where the change should apply. Add a comment with the opposite change at the point in the file when the default behavior should resume. Unless so countermanded, changes remain in effect for the remainder of the feature file.


  Scenario: Enabling/disabling a linter within a feature file

  Note: This example disables linters that are enabled by default but enabling a linter that is disabled by default works in the same manner

    Given the default linters are being used
    And a feature file model based on the following text:
      """
      # The comma is optional when listing linters. The following two lines are equivalent (although the second line is redundant in this case).
      # cuke_linter:disable CukeLinter::TestWithNoNameLinter, CukeLinter::FeatureWithoutDescriptionLinter
      # cuke_linter:disable CukeLinter::TestWithNoNameLinter CukeLinter::FeatureWithoutDescriptionLinter

      Feature: Feature with no description

        # cuke_linter:disable CukeLinter::ElementWithTooManyTagsLinter
        @tag_1 @tag_2 @tag_3 @tag_4 @tag_5 @tag_one_too_many
        Scenario:
          This scenario has no name and too many tags

          Given a step
          When a step
          Then a step
        # cuke_linter:enable CukeLinter::ElementWithTooManyTagsLinter

        @tag_1 @tag_2 @tag_3 @tag_4 @tag_5 @tag_one_too_many
        Scenario:
          This scenario also has no name and too many tags

          Given a step
          When a step
          Then a step
      """
    When the feature is linted
    Then the following problems are reported:
      | linter                       | problem                                           | location          |
      | ElementWithTooManyTagsLinter | Scenario has too many tags. 6 tags found (max 5). | <path_to_file>:18 |
    And the following problems are not reported:
      | linter                          | problem                                           | location          |
      | FeatureWithoutDescriptionLinter | Feature has no description                        | <path_to_file>:5  |
      | TestWithNoNameLinter            | Test does not have a name.                        | <path_to_file>:9  |
      | TestWithNoNameLinter            | Test does not have a name.                        | <path_to_file>:18 |
      | ElementWithTooManyTagsLinter    | Scenario has too many tags. 6 tags found (max 5). | <path_to_file>:9  |
