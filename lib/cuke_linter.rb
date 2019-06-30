require 'yaml'
require 'cuke_modeler'

require "cuke_linter/version"
require 'cuke_linter/formatters/pretty_formatter'
require 'cuke_linter/linters/linter'
require 'cuke_linter/linters/background_does_more_than_setup_linter'
require 'cuke_linter/linters/example_without_name_linter'
require 'cuke_linter/linters/feature_without_description_linter'
require 'cuke_linter/linters/feature_without_scenarios_linter'
require 'cuke_linter/linters/outline_with_single_example_row_linter'
require 'cuke_linter/linters/single_test_background_linter'
require 'cuke_linter/linters/step_with_end_period_linter'
require 'cuke_linter/linters/step_with_too_many_characters_linter'
require 'cuke_linter/linters/test_with_no_action_step_linter'
require 'cuke_linter/linters/test_with_no_verification_step_linter'
require 'cuke_linter/linters/test_with_too_many_steps_linter'


# The top level namespace used by this gem

module CukeLinter

  @original_linters = { 'BackgroundDoesMoreThanSetupLinter' => BackgroundDoesMoreThanSetupLinter.new,
                        'ExampleWithoutNameLinter'          => ExampleWithoutNameLinter.new,
                        'FeatureWithoutDescriptionLinter'   => FeatureWithoutDescriptionLinter.new,
                        'FeatureWithoutScenariosLinter'     => FeatureWithoutScenariosLinter.new,
                        'OutlineWithSingleExampleRowLinter' => OutlineWithSingleExampleRowLinter.new,
                        'SingleTestBackgroundLinter'        => SingleTestBackgroundLinter.new,
                        'StepWithEndPeriodLinter'           => StepWithEndPeriodLinter.new,
                        'TestWithNoActionStepLinter'        => TestWithNoActionStepLinter.new,
                        'TestWithNoVerificationStepLinter'  => TestWithNoVerificationStepLinter.new,
                        'StepWithTooManyCharactersLinter'   => StepWithTooManyCharactersLinter.new,
                        'TestWithTooManyStepsLinter'        => TestWithTooManyStepsLinter.new }


  # Configures linters based on the given options
  def self.load_configuration(config_file_path: nil, config: nil)
    # TODO: define what happens if both a configuration file and a configuration are provided. Merge them or have direct config take precedence? Both?

    unless config || config_file_path
      config_file_path = "#{Dir.pwd}/.cuke_linter"
      raise 'No configuration or configuration file given and no .cuke_linter file found' unless File.exist?(config_file_path)
    end

    config = config || YAML.load_file(config_file_path)

    common_config = config['AllLinters'] || {}
    to_delete     = []

    registered_linters.each_pair do |name, linter|
      linter_config = config[name] || {}
      final_config  = common_config.merge(linter_config)

      disabled = (final_config.key?('Enabled') && !final_config['Enabled'])

      # Just save it for afterwards because modifying a collection while iterating through it is not a good idea
      to_delete << name if disabled

      linter.configure(final_config) if linter.respond_to?(:configure)
    end

    to_delete.each { |linter_name| unregister_linter(linter_name) }
  end

  # Returns the registered linters to their default state
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

  # Lints the given model trees and file paths using the given linting objects and formatting the results with the given formatters and their respective output locations
  def self.lint(file_paths: [], model_trees: [], linters: self.registered_linters.values, formatters: [[CukeLinter::PrettyFormatter.new]])

    model_trees      = [CukeModeler::Directory.new(Dir.pwd)] if model_trees.empty? && file_paths.empty?
    file_path_models = file_paths.collect do |file_path|
      # TODO: raise exception unless path exists
      case
        when File.directory?(file_path)
          CukeModeler::Directory.new(file_path)
        when File.file?(file_path) && File.extname(file_path) == '.feature'
          CukeModeler::FeatureFile.new(file_path)
        else
          # Non-feature files are not modeled
      end
    end.compact # Compacting in order to get rid of any `nil` values left over from non-feature files

    linting_data = []
    model_sets   = model_trees + file_path_models

    model_sets.each do |model_tree|
      model_tree.each_model do |model|
        linters.each do |linter|
          # TODO: have linters lint only certain types of models
          #         linting_data.concat(linter.lint(model)) if relevant_model?(linter, model)

          result = linter.lint(model)

          if result
            result[:linter] = linter.name
            linting_data << result
          end
        end
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
