module CukeLinter
  class Linter

    def initialize(name:, message:, rule:)
      @name    = name
      @message = message
      @rule    = rule
    end

    def name
      @name
    end

    def lint(model)
      problem_found = @rule.call(model)

      if problem_found
        [{ problem: @message, location: "#{model.parent_model.path}:#{model.source_line}" }]
      else
        []
      end
    end

  end
end
