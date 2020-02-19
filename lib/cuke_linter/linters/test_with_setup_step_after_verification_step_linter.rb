module CukeLinter

  # A linter that detects scenarios and outlines that have a setup step that comes after a verification step

  class TestWithSetupStepAfterVerificationStepLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      dialect                 = DialectHelper.get_model_dialect(model)
      model_steps             = model.steps || []
      verification_step_found = false

      model_steps.each do |step|
        if verification_step_found
          return true if step.keyword == dialect.given_keyword
        else
          verification_step_found = step.keyword == dialect.then_keyword
        end
      end

      false
    end

    # The message used to describe the problem that has been found
    def message
      "Test has 'Given' step after 'Then' step."
    end

  end
end
