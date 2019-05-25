module CukeLinter

  # A linter that detects steps that end in a period

  class StepWithEndPeriodLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Step)

      model.text.end_with?('.')
    end

    # The message used to describe the problem that has been found
    def message
      'Step ends with a period'
    end

  end
end
