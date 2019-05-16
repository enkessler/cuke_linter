module CukeLinter

  # A linter that detects unnamed example groups

  class FeatureOrScenarioWithoutDescriptionLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Feature) || model.is_a?(CukeModeler::Scenario) 

      @model_classname = model.class.name.split('::').last

      model.description.nil? || model.description.empty?
    end

    # The message used to describe the problem that has been found
    def message
      "#{@model_classname} has no description"
    end

  end
end
