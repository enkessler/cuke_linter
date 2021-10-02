module CukeLinter

  # A helper module that generates linters for use in testing
  module LinterFactory

    module_function

    # TODO: Make it short
    # Dynamically defining a objects is not going to be short
    # rubocop:disable Metrics/MethodLength
    def generate_fake_linter(name: 'FakeLinter', finds_problems: true)
      linter = Object.new

      linter.define_singleton_method('lint') do |model|
        location = if model.respond_to?(:source_line)
                     "#{model.get_ancestor(:feature_file).path}:#{model.source_line}"
                   else
                     model.path
                   end
        problem  = @problem || "#{name} problem"

        return { problem: problem, location: location } if finds_problems

        nil
      end

      linter.define_singleton_method('name') do
        name
      end

      linter.define_singleton_method('configure') do |options|
        @problem = options['Problem'] if options['Problem']
      end

      linter
    end

    # rubocop:enable Metrics/MethodLength

    # TODO: Make it short and simple
    # Dynamically defining a class is not going to be short or simple
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def generate_fake_linter_class(module_name: nil, class_name: nil, linter_name: nil, finds_problems: nil)
      class_name     ||= 'FakeLinter'
      linter_name    ||= 'Some Name'
      finds_problems ||= true

      if module_name
        parent_module = if Kernel.const_defined?(module_name)
                          Kernel.const_get(module_name)
                        else
                          Kernel.const_set(module_name, Module.new)
                        end
      end

      (parent_module || Kernel).const_set(class_name, Class.new do

        define_method('lint') do |model|
          location = if model.respond_to?(:source_line)
                       "#{model.get_ancestor(:feature_file).path}:#{model.source_line}"
                     else
                       model.path
                     end
          problem  = @problem || "#{linter_name} problem"

          return { problem: problem, location: location } if finds_problems

          nil
        end

        define_method('name') do
          linter_name
        end

      end)
    end

    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  end
end
