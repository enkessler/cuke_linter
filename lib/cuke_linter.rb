require 'cuke_modeler'

require "cuke_linter/version"


module CukeLinter

  @registered_linters = {}

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

  def self.lint(model_tree: CukeModeler::Directory.new(Dir.pwd), linters: @registered_linters.values, formatters: 7)
    # puts "model tree: #{model_tree}"
    # puts "linters: #{linters}"
    # puts "formatters: #{formatters}"

    linting_data = []

    model_tree.each_model do |model|
      linters.each do |linter|
        # TODO: have linters lint only certain types of models
        #         linting_data.concat(linter.lint(model)) if relevant_model?(linter, model)
        linting_data.concat(linter.lint(model))
      end
    end

    # TODO: test that the Pretty formatter is the default formatter
    #     formatter = CukeLinter::PrettyFormatter.new
#     formatter = formatters.first

    # TODO: allow where output goes to be configurable (and then configure it to go somewhere else during testing so that the console isn't full of noise)
    # output = formatter.format(linting_data)

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
