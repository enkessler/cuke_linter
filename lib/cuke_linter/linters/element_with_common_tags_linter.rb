module CukeLinter

  # A linter that detects Gherkin elements that have the same tag on all of their taggable child elements
  class ElementWithCommonTagsLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model) # rubocop:disable Metrics/CyclomaticComplexity -- Rules can be tightened up later
      return false unless relevant_model?(model)

      @linted_model_class = model.class
      child_models        = model.send(child_accessor_method(model)) || []

      tag_sets      = child_models.collect { |child_model| child_model.tags || [] }
      tag_name_sets = tag_sets.collect { |tags| tags.map(&:name) }

      return false if tag_name_sets.count < 2

      !find_common_tag(tag_name_sets).nil?
    end

    # The message used to describe the problem that has been found
    def message
      class_name = @linted_model_class.name.split('::').last

      if class_name == 'Feature'
        "All tests in Feature have tag '#{@common_tag}'. Move tag to #{class_name} level."
      else
        "All Examples in Outline have tag '#{@common_tag}'. Move tag to #{class_name} level."
      end
    end


    private


    def relevant_model?(model)
      model.is_a?(CukeModeler::Feature) || model.is_a?(CukeModeler::Outline)
    end

    def child_accessor_method(model)
      model.is_a?(CukeModeler::Feature) ? :tests : :examples
    end

    def find_common_tag(tag_name_sets)
      @common_tag = tag_name_sets.reduce(:&).first
    end

  end
end
