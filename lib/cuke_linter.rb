require 'cuke_modeler'

require "cuke_linter/version"
require 'cuke_linter/formatters/pretty_formatter'
require 'cuke_linter/linters/feature_without_scenarios_linter'


module CukeLinter

  @registered_linters = { 'FeatureWithoutScenariosLinter' => FeatureWithoutScenariosLinter.new }

  def self.register_linter(linter:, name:)
    @registered_linters[name] = linter
  end

  def self.unregister_linter(name)
    @registered_linters.delete(name)
  end

  def self.registered_linters
    @registered_linters
  end

  def self.clear_registered_linters
    @registered_linters.clear
  end

  def self.lint(model_tree: CukeModeler::Directory.new(Dir.pwd), linters: @registered_linters.values, formatters: [[CukeLinter::PrettyFormatter.new]])
    # puts "model tree: #{model_tree}"
    # puts "linters: #{linters}"
    # puts "formatters: #{formatters}"

    linting_data = []

    model_tree.each_model do |model|
      linters.each do |linter|
        # TODO: have linters lint only certain types of models
        #         linting_data.concat(linter.lint(model)) if relevant_model?(linter, model)

        linted_data = linter.lint(model)
        linted_data.each { |data_point| data_point[:linter] = linter.name }
        linting_data.concat(linted_data)
      end
    end

    formatters.each do |formatter_output_pair|
      formatter = formatter_output_pair[0]
      location  = formatter_output_pair[1]

      formatted_data = formatter.format(linting_data)

      if location
        File.write(location, formatted_data)
      else
        puts formatted_data
      end
    end

    # TODO: keep this or always format data?
    linting_data
  end


# #   def self.relevant_model?(linter, model)
# #     model_classes = linter.class.target_model_types.map { |type| CukeModeler.const_get(type.to_s.capitalize.chop) }
# #     model_classes.any? { |clazz| model.is_a?(clazz) }
# #   end
# #
# #   private_class_method(:relevant_model?)

end
