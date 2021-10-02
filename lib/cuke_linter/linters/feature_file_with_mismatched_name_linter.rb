module CukeLinter

  # A linter that detects mismatched feature file names
  class FeatureFileWithMismatchedNameLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::FeatureFile)

      file_name    = File.basename(model.path, '.feature')
      feature_name = model.feature.name

      normalized_file_name    = file_name.downcase.delete('_ -')
      normalized_feature_name = feature_name.downcase.delete('_ -')

      normalized_file_name != normalized_feature_name
    end

    # The message used to describe the problem that has been found
    def message
      'Feature file name does not match feature name.'
    end

  end
end
