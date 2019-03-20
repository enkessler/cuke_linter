module CukeLinter

  # A linter that detects empty features

  class FeatureWithoutScenariosLinter

    # Returns the name of the linter
    def name
      'FeatureWithoutScenariosLinter'
    end

    # Lints the given model and returns linting data about said model
    def lint(model)
      return [] unless model.is_a?(CukeModeler::Feature)

      if model.tests.nil? || model.tests.empty?
        [{ problem: 'Feature has no scenarios', location: "#{model.parent_model.path}:#{model.source_line}" }]
      else
        []
      end
    end

  end
end
