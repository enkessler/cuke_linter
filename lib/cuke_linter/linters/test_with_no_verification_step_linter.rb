module CukeLinter

  # A linter that detects scenarios and outlines that do not have a verification (i.e. 'Then') step
  class TestWithNoVerificationStepLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @then_keywords = options['Then']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps      = model.steps || []
      background_steps = model.parent_model.has_background? ? model.parent_model.background.steps || [] : []
      all_steps        = model_steps + background_steps
      all_steps.none? { |step| then_keywords.include?(step.keyword) }
    end

    # The message used to describe the problem that has been found
    def message
      "Test does not have a 'Then' step."
    end

    private

    def then_keywords
      @then_keywords || [DEFAULT_THEN_KEYWORD]
    end

  end
end
