module CukeLinter

  # A linter that detects scenarios and outlines that have a setup step that comes after an action step

  class TestWithSetupStepAfterActionStepLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      dialect           = DialectHelper.get_model_dialect(model)
      model_steps       = model.steps || []
      action_step_found = false

      model_steps.each do |step|
        if action_step_found
          return true if step.keyword == dialect.given_keyword
        else
          action_step_found = step.keyword == dialect.when_keyword
        end
      end

      false
    end

    # The message used to describe the problem that has been found
    def message
      "Test has 'Given' step after 'When' step."
    end

  end
end
