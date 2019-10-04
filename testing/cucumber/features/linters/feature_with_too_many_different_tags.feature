Feature: Feature with too many different tags linter

  As a writer of documentation
  I want features to not contain too many different tags
  So that readers do not need to know too many different contexts


  Scenario: Linting
    Given a linter for features with too many different tags
    And the following feature:
      """
      # Total tag count doesn't matter. The count of unique tags is what matters.
      @tag_A @tag_A @tag_A @tag_A
      Feature:

        @tag_B @tag_C
        Scenario:
          * a step

        @tag_D @tag_E @tag_F @tag_G
        Scenario:
          * a step

        @tag_H @tag_I @tag_J
        Scenario:
          * a step

        @K
        Scenario:
          * a step
      """
    When it is linted
    Then an error is reported:
      | linter                                | problem                                                           | location         |
      | FeatureWithTooManyDifferentTagsLinter | Feature contains too many different tags. 11 tags found (max 10). | <path_to_file>:3 |

  Scenario: Configuration of tag count threshold
    Given a linter for features with too many different tags has been registered
    And the following configuration file:
      """
      FeatureWithTooManyDifferentTagsLinter:
        TagCountThreshold: 2
      """
    And the following feature:
      """
      @tag_A @tag_B @tag_C
      Feature:

        Scenario:
          * a step
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                                | problem                                                         | location         |
      | FeatureWithTooManyDifferentTagsLinter | Feature contains too many different tags. 3 tags found (max 2). | <path_to_file>:2 |
