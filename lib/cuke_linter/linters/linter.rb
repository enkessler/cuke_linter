module CukeLinter
  class Linter

    def initialize(name: nil, message: nil, rule: nil)
      @name    = name || self.class.name.split('::').last
      @message = message || "#{self.name} problem detected"
      @rule    = rule
    end

    def name
      @name
    end

    def lint(model)
      raise 'No linting rule provided!' unless @rule || respond_to?(:rule)

      problem_found = respond_to?(:rule) ? rule(model) : @rule.call(model)

      if problem_found
        problem_message = respond_to?(:message) ? message : @message

        [{ problem: problem_message, location: "#{model.parent_model.path}:#{model.source_line}" }]
      else
        []
      end
    end

  end
end
