module CukeLinter

  # A linter that detects scenarios and outlines that have an abnormal step flow

  class TestWithSetupStepAfterActionStepLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps       = model.steps || []
      action_step_found = false

      model_steps.each do |step|
        if action_step_found
          return true if step.keyword == 'Given'
        else
          action_step_found = step.keyword == 'When'
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
