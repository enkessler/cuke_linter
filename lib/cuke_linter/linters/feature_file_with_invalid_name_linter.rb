module CukeLinter

  # A linter that detects invalid feature file names
  class FeatureFileWithInvalidNameLinter < Linter

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
