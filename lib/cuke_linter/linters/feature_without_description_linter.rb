module CukeLinter

  # A linter that detects unnamed example groups

  class FeatureWithoutDescriptionLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Feature)

      model.description.nil? || model.description.empty?
    end

    # The message used to describe the problem that has been found
    def message
      "Feature has no description"
    end

  end
end
