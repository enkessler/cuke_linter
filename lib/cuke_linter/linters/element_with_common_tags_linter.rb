module CukeLinter

  # A linter that detects Gherkin elements that have the same tag on all of their taggable child elements

  class ElementWithCommonTagsLinter < Linter

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Feature) || model.is_a?(CukeModeler::Outline)

      @linted_model_class = model.class

      child_accessor_method = model.is_a?(CukeModeler::Feature) ? :tests : :examples
      child_models          = model.send(child_accessor_method) || []

      tag_sets      = child_models.collect { |child_model| child_model.tags || [] }
      tag_name_sets = tag_sets.collect { |tags| tags.map(&:name) }

      return false if tag_name_sets.count < 2

      @common_tag = tag_name_sets.reduce(:&).first

      !@common_tag.nil?
    end

    # The message used to describe the problem that has been found
    def message
      class_name = @linted_model_class.name.split('::').last

      case class_name
        when 'Feature'
          "All tests in #{class_name} have tag '#{@common_tag}'. Move tag to #{class_name} level."
        when 'Outline'
          "All Examples in #{class_name} have tag '#{@common_tag}'. Move tag to #{class_name} level."
        else
          raise("Linted an unexpected model type '#{class_name}'!")
      end
    end

  end
end
