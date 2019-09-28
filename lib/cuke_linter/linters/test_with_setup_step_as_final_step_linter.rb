module CukeLinter

  # A linter that detects scenarios and outlines that have a setup step as their final step

  class TestWithSetupStepAsFinalStepLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps = model.steps || []
      return false unless model_steps.last

      model_steps.last.keyword == 'Given'
    end

    # The message used to describe the problem that has been found
    def message
      "Test has 'Given' as the final step."
    end

  end
end
