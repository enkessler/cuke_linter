Feature: Element with common tags linter

  As a writer of documentation
  I want taggable elements to not needlessly have the same tags
  So that redundancy is minimized


  Scenario: Linting

  Note: Also works on outlines that have common tags on their examples

    Given a linter for elements with common tags
    And the following feature:
      """
      Feature:

        @same_tag
        Scenario:
          * a step

        @same_tag
        Scenario:
          * a step
      """
    When it is linted
    Then an error is reported:
      | linter                      | problem                                                               | location         |
      | ElementWithCommonTagsLinter | All tests in Feature have tag '@same_tag'. Move tag to Feature level. | <path_to_file>:1 |
