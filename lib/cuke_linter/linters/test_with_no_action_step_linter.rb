module CukeLinter

  # A linter that detects scenarios and outlines that do not have an action (i.e. 'When') step

  class TestWithNoActionStepLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps      = model.steps || []
      background_steps = model.parent_model.has_background? ? model.parent_model.background.steps || [] : []
      all_steps        = model_steps + background_steps
      all_steps.none? { |step| step.keyword == DialectHelper.get_model_dialect(model).when_keyword }
    end

    # The message used to describe the problem that has been found
    def message
      "Test does not have a 'When' step."
    end

  end
end
