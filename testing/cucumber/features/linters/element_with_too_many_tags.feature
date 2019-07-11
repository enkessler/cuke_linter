Feature: Element with too many tags linter

  As a reader of documentation
  I want taggable elements to not have an overabundance of tags
  So that I can concentrate on the content of the scenario


  Scenario: Linting

  Note: Also works on outlines, features, and examples
  Note: Tags inherited from other elements are not counted by default (see configuration options below)

    Given a linter for elements with too many tags
    And the following feature:
      """
      @this_tag_not_counted
      Feature:

        @tag_1 @tag_2 @tag_3 @tag_4 @tag_5 @tag_one_too_many
        Scenario:
          * a step
      """
    When it is linted
    Then an error is reported:
      | linter                       | problem                                           | location         |
      | ElementWithTooManyTagsLinter | Scenario has too many tags. 6 tags found (max 5). | <path_to_file>:5 |


  Scenario: Configuration of tag count threshold
    Given a linter for elements with too many tags has been registered
    And the following configuration file:
      """
      ElementWithTooManyTagsLinter:
        TagCountThreshold: 3
      """
    And the following feature:
      """
      Feature:

        @tag_1 @tag_2 @tag_3 @tag_one_too_many
        Scenario:
          * a step
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                       | problem                                           | location         |
      | ElementWithTooManyTagsLinter | Scenario has too many tags. 4 tags found (max 3). | <path_to_file>:4 |

  Scenario: Configuration of indirect tag count
    Given a linter for elements with too many tags has been registered
    And the following configuration file:
      """
      ElementWithTooManyTagsLinter:
        CountInheritedTags: true
      """
    And the following feature:
      """
      @this_tag_is_also_counted
      Feature:

        @tag_1 @tag_2 @tag_3 @tag_4 @tag_one_too_many
        Scenario:
          * a step
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                       | problem                                           | location         |
      | ElementWithTooManyTagsLinter | Scenario has too many tags. 6 tags found (max 5). | <path_to_file>:5 |
