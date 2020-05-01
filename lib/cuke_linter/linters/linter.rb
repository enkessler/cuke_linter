module CukeLinter

  # A generic linter that can be used to make arbitrary linting rules

  class Linter

    # Returns the name of the linter
    attr_reader :name

    # Creates a new linter object
    def initialize(name: nil, message: nil, rule: nil)
      @name    = name || self.class.name.split('::').last
      @message = message || "#{self.name} problem detected"
      @rule    = rule
    end

    # Lints the given model and returns linting data about said model
    def lint(model)
      raise 'No linting rule provided!' unless @rule || respond_to?(:rule)

      problem_found = respond_to?(:rule) ? rule(model) : @rule.call(model)

      if problem_found
        problem_message = respond_to?(:message) ? message : @message

        return { problem: problem_message, location: model.path } if model.is_a?(CukeModeler::FeatureFile)

        return { problem: problem_message, location: "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" }
      end

      nil
    end

  end
end
