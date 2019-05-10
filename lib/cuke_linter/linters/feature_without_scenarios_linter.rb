module CukeLinter

  # A linter that detects empty features

  class FeatureWithoutScenariosLinter < Linter

    def rule(model)
      return false unless model.is_a?(CukeModeler::Feature)

      model.tests.nil? || model.tests.empty?
    end

    def message
      'Feature has no scenarios'
    end

  end
end
