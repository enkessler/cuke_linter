module CukeLinter

  # A linter that detects features that contain too many different tags

  class FeatureWithTooManyDifferentTagsLinter < Linter

    # Changes the linting settings on the linter using the provided configuration
    def configure(options)
      @tag_threshold = options['TagCountThreshold']
    end

    # The rule used to determine if a model has a problem
    def rule(model)
      return false unless model.is_a?(CukeModeler::Feature)

      tags = model.tags

      model.each_descendant do |descendant_model|
        tags.concat(descendant_model.tags) if descendant_model.respond_to?(:tags)
      end

      tags = tags.collect(&:name).uniq

      @linted_tag_threshold = @tag_threshold || 10
      @linted_tag_count     = tags.count

      @linted_tag_count > @linted_tag_threshold
    end

    # The message used to describe the problem that has been found
    def message
      "Feature contains too many different tags. #{@linted_tag_count} tags found (max #{@linted_tag_threshold})."
    end

  end
end
