module CukeLinter

  # A linter that detects unnamed example groups

  class ExampleWithoutNameLinter < Linter

    def rule(model)
      return false unless model.is_a?(CukeModeler::Example)

      model.name.nil? || model.name.empty?
    end

    def message
      'Example has no name'
    end

  end
end
