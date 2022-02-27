module CukeLinter

  # A linter that detects test names that are too long
  class TestNameWithTooManyCharactersLinter < Linter

    # The threshold used if not otherwise configured
    DEFAULT_TEST_NAME_LENGTH_THRESHOLD = 80

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @test_name_length_threshold = options['TestNameLengthThreshold'] if options['TestNameLengthThreshold']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      @linted_test_name_length = model.name.nil? ? 0 : model.name.length

      @linted_test_name_length > test_name_length_threshold
    end

    # The message used to describe the problem that has been found
    def message
      "Scenario name is too long. #{@linted_test_name_length} characters found (max #{test_name_length_threshold})"
    end


    private


    # The maximum length allowable of a scenario name
    def test_name_length_threshold
      @test_name_length_threshold || DEFAULT_TEST_NAME_LENGTH_THRESHOLD
    end

  end
end
