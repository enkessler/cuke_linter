require 'cuke_modeler'

require "cuke_linter/version"
require 'cuke_linter/formatters/pretty_formatter'
require 'cuke_linter/linters/example_without_name_linter'
require 'cuke_linter/linters/feature_without_scenarios_linter'
require 'cuke_linter/linters/outline_with_single_example_row_linter'
require 'cuke_linter/linters/test_with_too_many_steps_linter'


# The top level namespace used by this gem

module CukeLinter

  @original_linters = { 'FeatureWithoutScenariosLinter'     => FeatureWithoutScenariosLinter.new,
                        'ExampleWithoutNameLinter'          => ExampleWithoutNameLinter.new,
                        'OutlineWithSingleExampleRowLinter' => OutlineWithSingleExampleRowLinter.new,
                        'TestWithTooManyStepsLinter'        => TestWithTooManyStepsLinter.new }

  def self.load_configuration(config_file_path: nil, config: nil)
    # TODO: define what happens if both a configuration file and a configuration are provided. Merge them or have direct config take precedence? Both?

    unless config || config_file_path
      config_file_path = "#{Dir.pwd}/.cuke_linter"
      raise 'No configuration or configuration file given and no .cuke_linter file found' unless File.exist?(config_file_path)
    end

    config = config || YAML.load_file(config_file_path)

    config.each_pair do |linter_name, options|
      unregister_linter(linter_name) if options.key?('Enabled') && !options['Enabled']

      registered_linters[linter_name].configure(options) if registered_linters[linter_name]
    end
  end

  def self.reset_linters
    @registered_linters = nil
  end

  # Registers for linting use the given linter object, tracked by the given name
  def self.register_linter(linter:, name:)
    self.registered_linters[name] = linter
  end

  # Unregisters the linter object tracked by the given name so that it is not used for linting
  def self.unregister_linter(name)
    self.registered_linters.delete(name)
  end

  # Lists the names of the currently registered linting objects
  def self.registered_linters
    @registered_linters ||= Marshal.load(Marshal.dump(@original_linters))
  end

  # Unregisters all currently registered linting objects
  def self.clear_registered_linters
    self.registered_linters.clear
  end

  # Lints the tree of model objects rooted at the given model using the given linting objects and formatting the results with the given formatters and their respective output locations
  def self.lint(model_tree: CukeModeler::Directory.new(Dir.pwd), linters: self.registered_linters.values, formatters: [[CukeLinter::PrettyFormatter.new]])
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
