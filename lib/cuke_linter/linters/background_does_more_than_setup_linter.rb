module CukeLinter

  # A linter that detects backgrounds that have non-setup steps
  class BackgroundDoesMoreThanSetupLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @when_keywords = options['When']
      @then_keywords = options['Then']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Background)

      model.steps.map(&:keyword).any? { |keyword| when_keywords.include?(keyword) || then_keywords.include?(keyword) }
    end

    # The message used to describe the problem that has been found
    def message
      'Background has non-setup steps'
    end

    private

    def when_keywords
      @when_keywords || [DEFAULT_WHEN_KEYWORD]
    end

    def then_keywords
      @then_keywords || [DEFAULT_THEN_KEYWORD]
    end

  end
end
