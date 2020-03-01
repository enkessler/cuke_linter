Feature: Background does more than setup linter

  As a reader of documentation
  I want to backgrounds to not contain actions or verifications
  So that what is being demonstrated in individual use cases is clear


  Scenario: Linting backgrounds with action steps
    Given a linter for backgrounds that do more than setup
    And the following feature:
      """
      Feature:

        Background:
          Given some setup
          When some action
      """
    When it is linted
    Then an error is reported:
      | linter                            | problem                        | location         |
      | BackgroundDoesMoreThanSetupLinter | Background has non-setup steps | <path_to_file>:3 |

  Scenario: Linting backgrounds with verification steps
    Given a linter for backgrounds that do more than setup
    And the following feature:
      """
      Feature:

        Background:
          Given some setup
          Then some verification
      """
    When it is linted
    Then an error is reported:
      | linter                            | problem                        | location         |
      | BackgroundDoesMoreThanSetupLinter | Background has non-setup steps | <path_to_file>:3 |

  Scenario: Linting backgrounds with only setup steps
    Given a linter for backgrounds that do more than setup
    And the following feature:
      """
      Feature:

        Background:
          Given some setup
          And some more setup
          * this is also setup
      """
    When it is linted
    Then no error is reported

  Scenario Outline: Configuration of keywords for different dialect
    Given a linter for backgrounds that do more than setup has been registered
    And the following configuration file:
      """
      BackgroundDoesMoreThanSetupLinter:
        Given:
          - Dado
        When:
          - Quando
        Then:
          - Então
          - Entao
      """
    And the following feature:
      """
      # language:pt
      Funcionalidade: Feature name

        Contexto: A Background in pt dialect
          Dado some setup in pt dialect
          <step>
      """
    When the configuration file is loaded
    And it is linted
    Then an error is reported:
      | linter                            | problem                        | location         |
      | BackgroundDoesMoreThanSetupLinter | Background has non-setup steps | <path_to_file>:4 |

    Examples:
      | step                                          |
      | Quando this is an action in pt dialect        |
      | Então this is a validation in pt dialect      |
      | Entao this is also a validation in pt dialect |
