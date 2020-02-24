module CukeLinter

  # A linter that detects backgrounds that have non-setup steps

  class BackgroundDoesMoreThanSetupLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      DialectHelper.set_when_keywords(options)
      DialectHelper.set_then_keywords(options)
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Background)

      model.steps.collect(&:keyword).any? { |keyword| DialectHelper.get_when_keywords.include?(keyword) || DialectHelper.get_then_keywords.include?(keyword) }
    end

    # The message used to describe the problem that has been found
    def message
      'Background has non-setup steps'
    end

  end
end
