module CukeLinter

  # A linter that detects unnamed example groups

  class ExampleWithoutNameLinter

    # Returns the name of the linter
    def name
      'ExampleWithoutNameLinter'
    end

    # Lints the given model and returns linting data about said model
    def lint(model)
      return [] unless model.is_a?(CukeModeler::Example)

      if model.name.nil? || model.name.empty?
        [{ problem: 'Example has no name', location: "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" }]
      else
        []
      end
    end

  end
end
