module CukeLinter

  # TODO: Make a new class that it is from the POV of a Feature model instead
  # A linter that detects scenarios and outlines within a feature that all share common beginning steps

  class TestShouldUseBackgroundLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      model_steps          = model.steps || []
      parent_feature_model = model.get_ancestor(:feature)

      return false unless parent_feature_model.tests.count > 1

      matching_steps     = all_first_steps_match?(parent_feature_model, model_steps)
      none_parameterized = no_parameterized_steps?(parent_feature_model)

      matching_steps && none_parameterized
    end

    # The message used to describe the problem that has been found
    def message
      'Test shares steps with all other tests in feature. Use a background.'
    end


    private


    def all_first_steps_match?(feature_model, model_steps)
      feature_model.tests.all? do |test|
        test_steps = test.steps || []
        test_steps.first == model_steps.first
      end
    end

    def no_parameterized_steps?(feature_model)
      feature_model.tests.none? do |test|
        next false if test.is_a?(CukeModeler::Scenario)

        test_steps          = test.steps || []
        params_used_by_test = test.examples.map(&:parameters).flatten.uniq

        next false unless test_steps.any?

        parameterized_step?(test_steps.first, parameters: params_used_by_test)
      end
    end

    def parameterized_step?(step_model, parameters:)
      parameters.any? do |parameter|
        parameter_string = "<#{parameter}>"

        parameterized_text?(step_model, parameter_string) ||
          parameterized_doc_string?(step_model, parameter_string) ||
          parameterized_table?(step_model, parameter_string)
      end
    end

    def parameterized_text?(step_model, parameter)
      step_model.text.include?(parameter)
    end

    def parameterized_doc_string?(step_model, parameter)
      return false unless step_model.block.is_a?(CukeModeler::DocString)

      step_model.block.content.include?(parameter)
    end

    def parameterized_table?(step_model, parameter)
      return false unless step_model.block.is_a?(CukeModeler::Table)

      step_model.block.rows.map(&:cells).flatten.map(&:value).any? { |cell_text| cell_text.include?(parameter) }
    end

  end

end
