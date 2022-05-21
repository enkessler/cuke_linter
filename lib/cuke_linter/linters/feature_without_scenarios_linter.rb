module CukeLinter

  # A linter that detects empty features
  class FeatureWithoutScenariosLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model) # rubocop:disable Metrics/CyclomaticComplexity # It's good enough
      return false unless model.is_a?(CukeModeler::Feature)

      feature_tests = model.tests && model.tests.any?
      rule_tests    = model.respond_to?(:rules) && # Earlier versions of CukeModeler did not have Rule models
                      model.rules && model.rules.any? { |rule| rule.tests && rule.tests.any? }

      !(feature_tests || rule_tests)
    end

    # The message used to describe the problem that has been found
    def message
      'Feature has no scenarios'
    end

  end
end
