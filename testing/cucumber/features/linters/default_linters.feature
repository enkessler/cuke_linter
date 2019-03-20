Feature: Default Linters

  As a user of cuke_linter
  I want a default set of linters to be used
  So that I don't have to specifically include every linter


  Scenario: Using the default linters
    Given no other linters have been registered
    Then the following linters are registered by default
      | ExampleWithoutNameLinter          |
      | FeatureWithoutScenariosLinter     |
      | OutlineWithSingleExampleRowLinter |
      | TestWithTooManyStepsLinter        |
