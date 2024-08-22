module CukeLinter # rubocop:disable Style/Documentation

  # Long names inherently result in long lines
  # rubocop:disable Layout/LineLength
  @original_linters = { 'BackgroundDoesMoreThanSetupLinter'            => BackgroundDoesMoreThanSetupLinter.new,
                        'ElementWithCommonTagsLinter'                  => ElementWithCommonTagsLinter.new,
                        'ElementWithDuplicateTagsLinter'               => ElementWithDuplicateTagsLinter.new,
                        'ElementWithTooManyTagsLinter'                 => ElementWithTooManyTagsLinter.new,
                        'ExampleWithoutNameLinter'                     => ExampleWithoutNameLinter.new,
                        'FeatureFileWithInvalidNameLinter'             => FeatureFileWithInvalidNameLinter.new,
                        'FeatureFileWithMismatchedNameLinter'          => FeatureFileWithMismatchedNameLinter.new,
                        'FeatureWithTooManyDifferentTagsLinter'        => FeatureWithTooManyDifferentTagsLinter.new,
                        'FeatureWithoutDescriptionLinter'              => FeatureWithoutDescriptionLinter.new,
                        'FeatureWithoutNameLinter'                     => FeatureWithoutNameLinter.new,
                        'FeatureWithoutScenariosLinter'                => FeatureWithoutScenariosLinter.new,
                        'OutlineWithSingleExampleRowLinter'            => OutlineWithSingleExampleRowLinter.new,
                        'SingleTestBackgroundLinter'                   => SingleTestBackgroundLinter.new,
                        'StepWithEndPeriodLinter'                      => StepWithEndPeriodLinter.new,
                        'StepWithTooManyCharactersLinter'              => StepWithTooManyCharactersLinter.new,
                        'TestShouldUseBackgroundLinter'                => TestShouldUseBackgroundLinter.new,
                        'TestWithActionStepAsFinalStepLinter'          => TestWithActionStepAsFinalStepLinter.new,
                        'TestWithBadNameLinter'                        => TestWithBadNameLinter.new,
                        'TestWithNoActionStepLinter'                   => TestWithNoActionStepLinter.new,
                        'TestWithNoNameLinter'                         => TestWithNoNameLinter.new,
                        'TestWithNoVerificationStepLinter'             => TestWithNoVerificationStepLinter.new,
                        'TestWithSetupStepAfterActionStepLinter'       => TestWithSetupStepAfterActionStepLinter.new,
                        'TestWithSetupStepAfterVerificationStepLinter' => TestWithSetupStepAfterVerificationStepLinter.new,
                        'TestWithSetupStepAsFinalStepLinter'           => TestWithSetupStepAsFinalStepLinter.new,
                        'TestWithTooManyStepsLinter'                   => TestWithTooManyStepsLinter.new,
                        'UniqueScenarioNamesLinter'                    => UniqueScenarioNamesLinter.new }
  # rubocop:enable Layout/LineLength

end
