require 'yaml'
require 'cuke_modeler'

require "cuke_linter/version"
require 'cuke_linter/formatters/pretty_formatter'
require 'cuke_linter/linters/linter'
require 'cuke_linter/linters/background_does_more_than_setup_linter'
require 'cuke_linter/linters/element_with_common_tags_linter'
require 'cuke_linter/linters/element_with_duplicate_tags_linter'
require 'cuke_linter/linters/element_with_too_many_tags_linter'
require 'cuke_linter/linters/example_without_name_linter'
require 'cuke_linter/linters/feature_file_with_invalid_name_linter'
require 'cuke_linter/linters/feature_file_with_mismatched_name_linter'
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
require 'cuke_linter/linters/test_with_bad_name_linter'
require 'cuke_linter/linters/test_with_no_action_step_linter'
require 'cuke_linter/linters/test_with_no_name_linter'
require 'cuke_linter/linters/test_with_no_verification_step_linter'
require 'cuke_linter/linters/test_with_setup_step_after_action_step_linter'
require 'cuke_linter/linters/test_with_setup_step_after_verification_step_linter'
require 'cuke_linter/linters/test_with_setup_step_as_final_step_linter'
require 'cuke_linter/linters/test_with_too_many_steps_linter'
require 'cuke_linter/default_linters'


# The top level namespace used by this gem

module CukeLinter

  # The default keyword that is considered a 'Given' keyword
  DEFAULT_GIVEN_KEYWORD = 'Given'.freeze
  # The default keyword that is considered a 'When' keyword
  DEFAULT_WHEN_KEYWORD = 'When'.freeze
  # The default keyword that is considered a 'Then' keyword
  DEFAULT_THEN_KEYWORD = 'Then'.freeze

  class << self

    # Configures linters based on the given options
    def load_configuration(config_file_path: nil, config: nil)
      # TODO: define what happens if both a configuration file and a configuration are
      # provided. Merge them or have direct config take precedence? Both?

      unless config || config_file_path
        config_file_path = "#{Dir.pwd}/.cuke_linter"
        message          = 'No configuration or configuration file given and no .cuke_linter file found'
        raise message unless File.exist?(config_file_path)
      end

      config ||= YAML.load_file(config_file_path)
      configure_linters(config, registered_linters)
    end

    # Returns the registered linters to their default state
    def reset_linters
      @registered_linters = nil
    end

    # Registers for linting use the given linter object, tracked by the given name
    def register_linter(linter:, name:)
      registered_linters[name] = linter
    end

    # Unregisters the linter object tracked by the given name so that it is not used for linting
    def unregister_linter(name)
      registered_linters.delete(name)
    end

    # Lists the names of the currently registered linting objects
    def registered_linters
      @registered_linters ||= Marshal.load(Marshal.dump(@original_linters))
    end

    # Unregisters all currently registered linting objects
    def clear_registered_linters
      registered_linters.clear
    end

    # Lints the given model trees and file paths using the given linting objects and formatting
    # the results with the given formatters and their respective output locations
    def lint(file_paths: nil, model_trees: nil, linters: nil, formatters: nil)
      # TODO: Test this?
      # Because directive memoization is based on a model's `#object_id` and Ruby reuses object IDs over the
      # life of a program as objects are garbage collected, it is not safe to remember the IDs forever. However,
      # models shouldn't get GC'd in the middle of the linting process and so the start of the linting process is
      # a good time to reset things
      @directives_for_feature_file = {}

      file_paths       ||= []
      model_trees      ||= []
      linters          ||= registered_linters.values
      formatters       ||= [[CukeLinter::PrettyFormatter.new]]

      model_trees      = [CukeModeler::Directory.new(Dir.pwd)] if model_trees.empty? && file_paths.empty?
      file_path_models = collect_file_path_models(file_paths)
      model_sets       = model_trees + file_path_models

      linting_data = lint_models(model_sets, linters)
      format_data(formatters, linting_data)

      linting_data
    end


    private


    def collect_file_path_models(file_paths)
      file_paths.collect do |file_path|
        # TODO: raise exception unless path exists?
        if File.directory?(file_path)
          CukeModeler::Directory.new(file_path)
        elsif File.file?(file_path) && File.extname(file_path) == '.feature'
          CukeModeler::FeatureFile.new(file_path)
        end
      end.compact # Compacting in order to get rid of any `nil` values left over from non-feature files
    end

    def lint_models(model_sets, linters)
      [].tap do |linting_data|
        model_sets.each do |model_tree|
          model_tree.each_model do |model|
            applicable_linters = relevant_linters_for_model(linters, model)
            applicable_linters.each do |linter|
              # TODO: have linters lint only certain types of models?
              #         linting_data.concat(linter.lint(model)) if relevant_model?(linter, model)

              result = linter.lint(model)

              if result
                result[:linter] = linter.name
                linting_data << result
              end
            end
          end
        end
      end
    end

    def relevant_linters_for_model(base_linters, model)
      feature_file_model = model.get_ancestor(:feature_file)

      # Linter directives are not applicable for directory and feature file models. Every other
      # model type should have a feature file ancestor from which to grab linter directive comments.
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

    def linter_directives_for_feature_file(feature_file_model)
      # IMPORTANT ASSUMPTION: Models never change during the life of a linting, so data only has to be gathered once
      existing_directives = @directives_for_feature_file[feature_file_model.object_id]

      return existing_directives if existing_directives

      directives = []

      feature_file_model.comments.each do |comment|
        pieces = comment.text.match(/#\s*cuke_linter:(disable|enable)\s+(.*)/)
        next unless pieces # Skipping non-directive file comments

        linter_classes = pieces[2].tr(',', ' ').split(' ')
        linter_classes.each do |clazz|
          directives << { linter_class:   Kernel.const_get(clazz),
                          enabled_status: pieces[1] != 'disable',
                          source_line:    comment.source_line }
        end
      end

      # Make sure that the directives are in the same order as they appear in the source file
      directives = directives.sort_by { |a| a[:source_line] }

      @directives_for_feature_file[feature_file_model.object_id] = directives
    end

    def dynamic_linters
      # No need to keep making new ones over and over...
      @dynamic_linters ||= Hash.new { |hash, key| hash[key] = key.new }
      # return @dynamic_linters if @dynamic_linters
      #
      # @dynamic_linters = {}
    end

    def format_data(formatters, linting_data)
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
    end

    def configure_linters(configuration, linters)
      common_config = configuration['AllLinters'] || {}
      to_delete     = []

      linters.each_pair do |name, linter|
        linter_config = configuration[name] || {}
        final_config  = common_config.merge(linter_config)

        disabled = (final_config.key?('Enabled') && !final_config['Enabled'])

        # Just save it for afterwards because modifying a collection while iterating through it is not a good idea
        to_delete << name if disabled

        linter.configure(final_config) if linter.respond_to?(:configure)
      end

      to_delete.each { |linter_name| unregister_linter(linter_name) }
    end

    # Not linting unused code
    # rubocop:disable Metrics/LineLength
    #   def self.relevant_model?(linter, model)
    #     model_classes = linter.class.target_model_types.map { |type| CukeModeler.const_get(type.to_s.capitalize.chop) }
    #     model_classes.any? { |clazz| model.is_a?(clazz) }
    #   end
    #
    #   private_class_method(:relevant_model?)
    # rubocop:enable Metrics/LineLength

  end
end
