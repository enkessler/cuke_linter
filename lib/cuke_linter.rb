require 'yaml'
require 'cuke_modeler'

require 'cuke_linter/version'
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
require 'cuke_linter/linters/test_name_with_too_many_characters_linter'
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
require 'cuke_linter/configuration'
require 'cuke_linter/default_linters'
require 'cuke_linter/gherkin'
require 'cuke_linter/linter_registration'


# The top level namespace used by this gem
module CukeLinter

  extend CukeLinter::Configuration
  extend CukeLinter::LinterRegistration

  class << self

    # Lints the given model trees and file paths using the given linting objects and formatting
    # the results with the given formatters and their respective output locations
    def lint(file_paths: [], model_trees: [], linters: registered_linters.values, formatters: [[CukeLinter::PrettyFormatter.new]]) # rubocop:disable Layout/LineLength
      # TODO: Test this?
      # Because directive memoization is based on a model's `#object_id` and Ruby reuses object IDs over the
      # life of a program as objects are garbage collected, it is not safe to remember the IDs forever. However,
      # models shouldn't get GC'd in the middle of the linting process and so the start of the linting process is
      # a good time to reset things
      @directives_for_feature_file = {}.compare_by_identity

      model_trees                  = [CukeModeler::Directory.new(Dir.pwd)] if model_trees.empty? && file_paths.empty?
      file_path_models             = collect_file_path_models(file_paths)
      model_sets                   = model_trees + file_path_models

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

      determine_final_linters(base_linters, disabled_linter_classes, enabled_linter_classes)
    end

    def determine_final_linters(base_linters, disabled_linter_classes, enabled_linter_classes)
      final_linters = base_linters.reject { |linter| disabled_linter_classes.include?(linter.class) }

      enabled_linter_classes.each do |clazz|
        final_linters << dynamic_linters[clazz] unless final_linters.map(&:class).include?(clazz)
      end

      final_linters
    end

    def linter_directives_for_feature_file(feature_file_model)
      # IMPORTANT ASSUMPTION: Models never change during the life of a linting, so data only has to be gathered once
      existing_directives = @directives_for_feature_file[feature_file_model]

      return existing_directives if existing_directives

      directives = gather_directives_in_feature(feature_file_model)

      # Make sure that the directives are in the same order as they appear in the source file
      directives = directives.sort_by { |a| a[:source_line] }

      @directives_for_feature_file[feature_file_model] = directives
    end

    def gather_directives_in_feature(feature_file_model)
      [].tap do |directives|
        feature_file_model.comments.each do |comment|
          pieces = comment.text.match(/#\s*cuke_linter:(disable|enable)\s+(.*)/)
          next unless pieces # Skipping non-directive file comments

          linter_classes = pieces[2].tr(',', ' ').split
          linter_classes.each do |clazz|
            directives << { linter_class:   Kernel.const_get(clazz),
                            enabled_status: pieces[1] != 'disable',
                            source_line:    comment.source_line }
          end
        end
      end
    end

    def dynamic_linters
      # No need to keep making new ones over and over...
      @dynamic_linters ||= Hash.new { |hash, key| hash[key] = key.new }
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

    # Not linting unused code
    # rubocop:disable Layout/LineLength
    #   def self.relevant_model?(linter, model)
    #     model_classes = linter.class.target_model_types.map { |type| CukeModeler.const_get(type.to_s.capitalize.chop) }
    #     model_classes.any? { |clazz| model.is_a?(clazz) }
    #   end
    #
    #   private_class_method(:relevant_model?)
    # rubocop:enable Layout/LineLength

  end
end
