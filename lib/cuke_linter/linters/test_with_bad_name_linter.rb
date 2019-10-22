module CukeLinter

  # A linter that detects scenarios and outlines that have a bad name

  class TestWithBadNameLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      lowercase_name = model.name.downcase
      return true if lowercase_name.include?('test') ||
                     lowercase_name.include?('verif') ||
                     lowercase_name.include?('check')
      false
    end

    # The message used to describe the problem that has been found
    def message
      '"Test", "Verify" and "Check" should not be used in scenario names.'
    end

  end
end
