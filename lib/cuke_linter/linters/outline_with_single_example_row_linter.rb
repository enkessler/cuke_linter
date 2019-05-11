module CukeLinter

  # A linter that detects outlines that don't have multiple example rows

  class OutlineWithSingleExampleRowLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Outline)
      return false if model.examples.nil?

      examples_rows = model.examples.collect(&:argument_rows).flatten

      examples_rows.count == 1
    end

    # The message used to describe the problem that has been found
    def message
      'Outline has only one example row'
    end

  end
end
