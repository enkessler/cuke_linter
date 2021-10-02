module CukeLinter

  # A linter that detects scenarios and outlines that do not have a name
  class TestWithNoNameLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model.name.nil? || model.name.empty?
    end

    # The message used to describe the problem that has been found
    def message
      'Test does not have a name.'
    end

  end
end
