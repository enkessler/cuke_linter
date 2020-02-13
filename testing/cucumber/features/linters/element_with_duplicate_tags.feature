Feature: Element with duplicate tags linter

  As a writer of documentation
  I want taggable elements to not have duplicate of tags
  So that redundancy is minimized


  Scenario: Linting

  Note: Also works on outlines, features, and examples

    Given a linter for elements with duplicate tags
    And the following feature:
      """
      Feature:

        @same_tag @a_different_tag @same_tag
        Scenario:
          * a step
      """
    When it is linted
    Then an error is reported:
      | linter                         | problem                                 | location         |
      | ElementWithDuplicateTagsLinter | Scenario has duplicate tag '@same_tag'. | <path_to_file>:4 |


  Scenario: Configuration of indirect tag inclusion (turned off)

  Note: Tags inherited from other elements are not included by default

    Given a linter for elements with duplicate tags has been registered
    And the following configuration file:
      """
      ElementWithDuplicateTagsLinter:
        IncludeInheritedTags: false
      """
    And the following feature:
      """
      @same_tag
      Feature:

        @same_tag
        Scenario:
          * a step
      """
    When the configuration file is loaded
    And it is linted
    Then no error is reported


  Scenario: Configuration of indirect tag inclusion (turned on)
    Given a linter for elements with duplicate tags has been registered
    And the following configuration file:
      """
      ElementWithDuplicateTagsLinter:
        IncludeInheritedTags: true
      """
    And the following feature:
      """
      @same_tag
      Feature:

        @same_tag
        Scenario:
          * a step
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                         | problem                                 | location         |
      | ElementWithDuplicateTagsLinter | Scenario has duplicate tag '@same_tag'. | <path_to_file>:5 |
