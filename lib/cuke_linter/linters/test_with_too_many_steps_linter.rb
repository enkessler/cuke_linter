module CukeLinter

  # A linter that detects scenarios and outlines that have too many steps

  class TestWithTooManyStepsLinter

    # Returns the name of the linter
    def name
      'TestWithTooManyStepsLinter'
    end

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @step_threshold = options['StepThreshold'] if options['StepThreshold']
    end

    # Lints the given model and returns linting data about said model
    def lint(model)
      return [] unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      step_count     = model.steps.nil? ? 0 : model.steps.count
      step_threshold = @step_threshold || 10

      if step_count > step_threshold
        [{ problem: "Test has too many steps. #{step_count} steps found (max #{step_threshold})", location: "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" }]
      else
        []
      end
    end

  end
end
