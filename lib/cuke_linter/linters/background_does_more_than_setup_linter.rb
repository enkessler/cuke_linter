module CukeLinter

  # A linter that detects backgrounds that have non-setup steps

  class BackgroundDoesMoreThanSetupLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Background)

      dialect = DialectHelper.get_model_dialect(model)
      model.steps.collect(&:keyword).any? { |keyword| (keyword == dialect.when_keyword) || (keyword == dialect.then_keyword) }
    end

    # The message used to describe the problem that has been found
    def message
      'Background has non-setup steps'
    end

  end
end
