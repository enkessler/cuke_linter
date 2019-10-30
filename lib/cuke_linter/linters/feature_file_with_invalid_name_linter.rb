module CukeLinter

  # A linter that detects invalid feature file names

  class FeatureFileWithInvalidNameLinter < Linter

    #TODO: Fix generic version of lint to be inclusive of this use case

    # Lints the given model and returns linting data about said model
    def lint(model)
      problem_found = rule(model)

      if problem_found
        problem_message = respond_to?(:message) ? message : @message

        { problem: problem_message, location: "#{model.path}" }
      else
        nil
      end
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::FeatureFile)

      base = File.basename model.path
      base =~ /[A-Z -]/
    end

    # The message used to describe the problem that has been found
    def message
      'Feature files should be snake_cased.'
    end

  end
end
