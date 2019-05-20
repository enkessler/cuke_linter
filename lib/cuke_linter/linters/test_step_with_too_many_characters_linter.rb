module CukeLinter

  # A linter that detects scenarios and outlines that have too many steps

  class TestStepWithTooManyCharactersLinter < Linter
  
    DEFAULT_STEP_LENGTH_THRESHOLD = 120

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @step_length_threshold = options['StepLengthThreshold'] if options['StepLengthThreshold']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Step)
        
      @linted_step_length = model.text&.length || 0

      @linted_step_length > step_length_threshold
    end

    # The message used to describe the problem that has been found
    def message
      "Step is too long. #{@linted_step_length} characters found (max #{step_length_threshold})"
    end

    # The maximum length allowable of a step
    def step_length_threshold
      @step_length_threshold || DEFAULT_STEP_LENGTH_THRESHOLD
    end

  end
end
