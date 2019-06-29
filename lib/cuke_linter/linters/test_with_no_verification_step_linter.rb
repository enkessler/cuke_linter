module CukeLinter

  # A linter that detects scenarios and outlines that do not have a verification (i.e. 'Then') step

  # class TestWithNoVerificationStepLinter
  class TestWithNoVerificationStepLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model.steps.nil? || model.steps.none? { |step| step.keyword == 'Then' }
    end

    # The message used to describe the problem that has been found
    def message
      "Test does not have a 'Then' step."
    end

  end
end
