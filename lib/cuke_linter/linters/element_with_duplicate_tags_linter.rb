module CukeLinter

  # A linter that detects taggable Gherkin elements that have duplicate tags
  class ElementWithDuplicateTagsLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @tag_inheritance = options['IncludeInheritedTags']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless relevant_model?(model)

      @linted_model_class = model.class

      relevant_tags = if @tag_inheritance
                        model.all_tags
                      else
                        model.tags || []
                      end
      tag_names     = relevant_tags.map(&:name)

      @duplicate_tag = tag_names.find { |tag| tag_names.count(tag) > 1 }

      !@duplicate_tag.nil?
    end

    # The message used to describe the problem that has been found
    def message
      class_name = @linted_model_class.name.split('::').last

      "#{class_name} has duplicate tag '#{@duplicate_tag}'."
    end


    private


    def relevant_model?(model)
      model.is_a?(CukeModeler::Feature) ||
        model.is_a?(CukeModeler::Scenario) ||
        model.is_a?(CukeModeler::Outline) ||
        model.is_a?(CukeModeler::Example)
    end

  end
end
