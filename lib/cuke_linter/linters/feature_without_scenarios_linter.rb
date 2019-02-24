module CukeLinter
  class FeatureWithoutScenariosLinter
#     # class FeatureWithoutScenariosLinter < BaseLinter
#
# #     targets :features

    def name
      'FeatureWithoutScenariosLinter'
    end

    def lint(model)
      return [] unless model.is_a?(CukeModeler::Feature)

      if model.tests.nil? || model.tests.empty?
        [{ problem: 'Feature has no scenarios', location: "#{model.parent_model.path}:#{model.source_line}" }]
      else
        []
      end
    end

  end
end
