module CukeLinter

  # A linter that detects unnamed example groups
  class ExampleWithoutNameLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Example)

      model.name.nil? || model.name.empty?
    end

    # The message used to describe the problem that has been found
    def message
      'Example grouping has no name'
    end

  end
end
