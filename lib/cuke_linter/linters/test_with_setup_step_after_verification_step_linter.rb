module CukeLinter

  # A linter that detects scenarios and outlines that have a setup step that comes after a verification step
  class TestWithSetupStepAfterVerificationStepLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @given_keywords = options['Given']
      @then_keywords  = options['Then']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps             = model.steps || []
      verification_step_found = false

      model_steps.each do |step|
        if verification_step_found
          return true if given_keywords.include?(step.keyword)
        else
          verification_step_found = then_keywords.include?(step.keyword)
        end
      end

      false
    end

    # The message used to describe the problem that has been found
    def message
      "Test has 'Given' step after 'Then' step."
    end

    private

    def given_keywords
      @given_keywords || [DEFAULT_GIVEN_KEYWORD]
    end

    def then_keywords
      @then_keywords || [DEFAULT_THEN_KEYWORD]
    end

  end
end
