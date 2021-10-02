module CukeLinter

  # A linter that detects backgrounds that apply to only one test
  class SingleTestBackgroundLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Background)

      model.parent_model.tests.count == 1
    end

    # The message used to describe the problem that has been found
    def message
      'Background used with only one test'
    end

  end
end
