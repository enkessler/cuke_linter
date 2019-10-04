module CukeLinter

  # A linter that detects scenarios and outlines within a feature that all share common beginning steps

  class TestShouldUseBackgroundLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps          = model.steps || []
      parent_feature_model = model.get_ancestor(:feature)

      return false unless parent_feature_model.tests.count > 1

      parent_feature_model.tests.all? do |test|
        test_steps = test.steps || []
        test_steps.first == model_steps.first
      end
    end

    # The message used to describe the problem that has been found
    def message
      'Test shares steps with all other tests in feature. Use a background.'
    end

  end
end
