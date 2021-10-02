module CukeLinter

  # A linter that detects scenarios and outlines that have a setup step as their final step
  class TestWithSetupStepAsFinalStepLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @given_keywords = options['Given']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps = model.steps || []
      return false unless model_steps.last

      given_keywords.include?(model_steps.last.keyword)
    end

    # The message used to describe the problem that has been found
    def message
      "Test has 'Given' as the final step."
    end

    private

    def given_keywords
      @given_keywords || [DEFAULT_GIVEN_KEYWORD]
    end

  end
end
