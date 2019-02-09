Feature: Default Linters


  Scenario: Using the default linters
    Given no other linters have been registered
    Then the following linters are registered by default
      | FeatureWithoutScenariosLinter |
