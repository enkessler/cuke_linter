module CukeLinter
  class ExampleWithoutNameLinter

    def name
      'ExampleWithoutNameLinter'
    end

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
