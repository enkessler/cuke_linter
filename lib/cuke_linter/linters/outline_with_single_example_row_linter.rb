module CukeLinter

  # A linter that detects outlines that don't have multiple example rows

  class OutlineWithSingleExampleRowLinter

    # Returns the name of the linter
    def name
      'OutlineWithSingleExampleRowLinter'
    end

    # Lints the given model and returns linting data about said model
    def lint(model)
      return [] unless model.is_a?(CukeModeler::Outline)
      return [] if model.examples.nil?

      examples_rows = model.examples.collect(&:argument_rows).flatten

      if examples_rows.count == 1
        [{ problem: 'Outline has only one example row', location: "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" }]
      else
        []
      end
    end

  end
end
