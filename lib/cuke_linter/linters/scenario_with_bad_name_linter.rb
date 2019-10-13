module CukeLinter

  # A linter that detects outlines and scenarios that have a 'bad' name

  class ScenarioWithBadNameLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Scenario) || model.is_a?(CukeModeler::Outline)

      %w[test verif check].map do |bad_word|
        model.name.downcase.include? bad_word
      end.any?
    end

    # The message used to describe the problem that has been found
    def message
      'Prefer name your scenarios using "Given" and "When" rather than "test", "verify" or "check".'
    end

  end
end
