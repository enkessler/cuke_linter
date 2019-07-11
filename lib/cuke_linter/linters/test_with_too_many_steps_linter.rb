module CukeLinter

  # A linter that detects scenarios and outlines that have too many steps

  class TestWithTooManyStepsLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @step_threshold = options['StepThreshold'] if options['StepThreshold']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      @linted_step_count     = model.steps.nil? ? 0 : model.steps.count
      @linted_step_threshold = @step_threshold || 10

      @linted_step_count > @linted_step_threshold
    end

    # The message used to describe the problem that has been found
    def message
      "Test has too many steps. #{@linted_step_count} steps found (max #{@linted_step_threshold})."
    end

  end
end
