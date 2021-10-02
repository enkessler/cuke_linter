module CukeLinter

  # A linter that detects empty features
  class FeatureWithoutScenariosLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Feature)

      model.tests.nil? || model.tests.empty?
    end

    # The message used to describe the problem that has been found
    def message
      'Feature has no scenarios'
    end

  end
end
