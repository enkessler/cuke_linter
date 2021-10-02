module CukeLinter

  # A linter that detects features that don't have a name
  class FeatureWithoutNameLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Feature)

      model.name.nil? || model.name.empty?
    end

    # The message used to describe the problem that has been found
    def message
      'Feature does not have a name.'
    end

  end
end
