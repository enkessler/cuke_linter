require 'yaml'
require 'cuke_modeler'

require "cuke_linter/version"
require 'cuke_linter/formatters/pretty_formatter'
require 'cuke_linter/linters/linter'
require 'cuke_linter/linters/background_does_more_than_setup_linter'
require 'cuke_linter/linters/element_with_too_many_tags_linter'
require 'cuke_linter/linters/example_without_name_linter'
require 'cuke_linter/linters/feature_with_too_many_different_tags_linter'
require 'cuke_linter/linters/feature_without_name_linter'
require 'cuke_linter/linters/feature_without_description_linter'
require 'cuke_linter/linters/feature_without_scenarios_linter'
require 'cuke_linter/linters/outline_with_single_example_row_linter'
require 'cuke_linter/linters/single_test_background_linter'
require 'cuke_linter/linters/step_with_end_period_linter'
require 'cuke_linter/linters/step_with_too_many_characters_linter'
require 'cuke_linter/linters/test_should_use_background_linter'
require 'cuke_linter/linters/test_with_action_step_as_final_step_linter'
require 'cuke_linter/linters/test_with_no_action_step_linter'
require 'cuke_linter/linters/test_with_no_name_linter'
require 'cuke_linter/linters/test_with_no_verification_step_linter'
require 'cuke_linter/linters/test_with_setup_step_after_action_step_linter'
require 'cuke_linter/linters/test_with_setup_step_after_verification_step_linter'
require 'cuke_linter/linters/test_with_setup_step_as_final_step_linter'
require 'cuke_linter/linters/test_with_too_many_steps_linter'


# The top level namespace used by this gem

module CukeLinter

  @original_linters = { 'BackgroundDoesMoreThanSetupLinter'            => BackgroundDoesMoreThanSetupLinter.new,
                        'ElementWithTooManyTagsLinter'                 => ElementWithTooManyTagsLinter.new,
                        'ExampleWithoutNameLinter'                     => ExampleWithoutNameLinter.new,
                        'FeatureWithTooManyDifferentTagsLinter'        => FeatureWithTooManyDifferentTagsLinter.new,
                        'FeatureWithoutDescriptionLinter'              => FeatureWithoutDescriptionLinter.new,
                        'FeatureWithoutNameLinter'                     => FeatureWithoutNameLinter.new,
                        'FeatureWithoutScenariosLinter'                => FeatureWithoutScenariosLinter.new,
                        'OutlineWithSingleExampleRowLinter'            => OutlineWithSingleExampleRowLinter.new,
                        'SingleTestBackgroundLinter'                   => SingleTestBackgroundLinter.new,
                        'StepWithEndPeriodLinter'                      => StepWithEndPeriodLinter.new,
                        'StepWithTooManyCharactersLinter'              => StepWithTooManyCharactersLinter.new,
                        'TestShouldUseBackgroundLinter'                => TestShouldUseBackgroundLinter.new,
                        'TestWithActionStepAsFinalStepLinter'          => TestWithActionStepAsFinalStepLinter.new,
                        'TestWithNoActionStepLinter'                   => TestWithNoActionStepLinter.new,
                        'TestWithNoNameLinter'                         => TestWithNoNameLinter.new,
                        'TestWithNoVerificationStepLinter'             => TestWithNoVerificationStepLinter.new,
                        'TestWithSetupStepAfterActionStepLinter'       => TestWithSetupStepAfterActionStepLinter.new,
                        'TestWithSetupStepAfterVerificationStepLinter' => TestWithSetupStepAfterVerificationStepLinter.new,
                        'TestWithSetupStepAsFinalStepLinter'           => TestWithSetupStepAsFinalStepLinter.new,
                        'TestWithTooManyStepsLinter'                   => TestWithTooManyStepsLinter.new }


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

    # TODO: Test this?
    # Because directive memoization is based on a model's `#object_id` and Ruby reuses object IDs over the life
    # life of a program as objects are garbage collected, it is not safe to remember the IDs forever. However,
    # models shouldn't get GC'd in the middle of the linting process and so the start of the linting process is
    # a good time to reset things
    @directives_for_feature_file = {}

    model_trees                  = [CukeModeler::Directory.new(Dir.pwd)] if model_trees.empty? && file_paths.empty?
    file_path_models             = file_paths.collect do |file_path|
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
        applicable_linters = relevant_linters_for_model(linters, model)
        applicable_linters.each do |linter|
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


  def self.relevant_linters_for_model(base_linters, model)
    feature_file_model = model.get_ancestor(:feature_file)

    # Linter directives are not applicable for directory and feature file models. Every other model type should have a feature file ancestor from which to grab linter directive comments.
    return base_linters if feature_file_model.nil?

    linter_modifications_for_model = {}

    linter_directives_for_feature_file(feature_file_model).each do |directive|
      # Assuming that the directives are in the same order that they appear in the file
      break if directive[:source_line] > model.source_line

      linter_modifications_for_model[directive[:linter_class]] = directive[:enabled_status]
    end

    disabled_linter_classes = linter_modifications_for_model.reject { |_name, status| status }.keys
    enabled_linter_classes  = linter_modifications_for_model.select { |_name, status| status }.keys

    final_linters = base_linters.reject { |linter| disabled_linter_classes.include?(linter.class) }
    enabled_linter_classes.each do |clazz|
      final_linters << dynamic_linters[clazz] unless final_linters.map(&:class).include?(clazz)
    end

    final_linters
  end

  private_class_method(:relevant_linters_for_model)


  def self.linter_directives_for_feature_file(feature_file_model)
    # IMPORTANT ASSUMPTION: Models never change during the life of a linting, so data only has to be gathered once
    return @directives_for_feature_file[feature_file_model.object_id] if @directives_for_feature_file[feature_file_model.object_id]


    @directives_for_feature_file[feature_file_model.object_id] = []

    feature_file_model.comments.each do |comment|
      pieces = comment.text.match(/#\s*cuke_linter:(disable|enable)\s+(.*)/)
      next unless pieces # Skipping non-directive file comments

      linter_classes = pieces[2].gsub(',', ' ').split(' ')
      linter_classes.each do |clazz|
        @directives_for_feature_file[feature_file_model.object_id] << { linter_class:   Kernel.const_get(clazz),
                                                                        enabled_status: pieces[1] != 'disable',
                                                                        source_line:    comment.source_line }
      end
    end

    # Make sure that the directives are in the same order as they appear in the source file
    @directives_for_feature_file[feature_file_model.object_id] = @directives_for_feature_file[feature_file_model.object_id].sort { |a, b| a[:source_line] <=> b[:source_line] }


    @directives_for_feature_file[feature_file_model.object_id]
  end

  private_class_method(:linter_directives_for_feature_file)

  def self.dynamic_linters
    # No need to keep making new ones over and over...
    @dynamic_linters ||= Hash.new { |hash, key| hash[key] = key.new }
    # return @dynamic_linters if @dynamic_linters
    #
    # @dynamic_linters = {}
  end

  private_class_method(:dynamic_linters)


# #   def self.relevant_model?(linter, model)
# #     model_classes = linter.class.target_model_types.map { |type| CukeModeler.const_get(type.to_s.capitalize.chop) }
# #     model_classes.any? { |clazz| model.is_a?(clazz) }
# #   end
# #
# #   private_class_method(:relevant_model?)

end
