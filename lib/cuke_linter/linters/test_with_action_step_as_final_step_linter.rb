module CukeLinter

  # A linter that detects scenarios and outlines that have an action step as their final step

  class TestWithActionStepAsFinalStepLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps = model.steps || []
      return false unless model_steps.last

      model_steps.last.keyword == 'When'
    end

    # The message used to describe the problem that has been found
    def message
      "Test has 'When' as the final step."
    end

  end
end
