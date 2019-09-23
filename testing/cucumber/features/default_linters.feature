Feature: Default Linters

  As a user of cuke_linter
  I want a default set of linters to be used
  So that I don't have to specifically include every linter


  Scenario: Using the default linters
    Given no other linters have been registered or unregistered
    Then the following linters are registered by default
      | BackgroundDoesMoreThanSetupLinter     |
      | ElementWithTooManyTagsLinter          |
      | ExampleWithoutNameLinter              |
      | FeatureWithTooManyDifferentTagsLinter |
      | FeatureWithoutDescriptionLinter       |
      | FeatureWithoutNameLinter              |
      | FeatureWithoutScenariosLinter         |
      | OutlineWithSingleExampleRowLinter     |
      | SingleTestBackgroundLinter            |
      | StepWithEndPeriodLinter               |
      | StepWithTooManyCharactersLinter       |
      | TestShouldUseBackgroundLinter         |
      | TestWithNoActionStepLinter            |
      | TestWithNoNameLinter                  |
      | TestWithNoVerificationStepLinter      |
      | TestWithTooManyStepsLinter            |


  Scenario: Registering new linters
    Given no linters are currently registered
    When the following code is used:
      """
      linter_object = <code_to_generate_a_new_linter_instance>

      CukeLinter.register_linter(linter: linter_object,  name: 'MyNewLinter')
      """
    Then the following linters are registered
      | MyNewLinter |

  Scenario: Unregistering existing linters
    Given a linter registered as "SomeLinter"
    When the following code is used:
      """
      linter_object = <code_to_generate_a_new_linter_instance>

      CukeLinter.unregister_linter('SomeLinter')
      """
    Then the linter "SomeLinter" is no longer registered
