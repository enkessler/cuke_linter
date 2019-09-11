module CukeLinter
  module LinterFactory

    def self.generate_fake_linter(name: 'FakeLinter', finds_problems: true)
      linter = Object.new

      linter.define_singleton_method('lint') do |model|
        location = model.respond_to?(:source_line) ? "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" : model.path
        problem  = @problem || "#{name} problem"

        if finds_problems
          { problem:  problem,
            location: location }
        else
          nil
        end
      end

      linter.define_singleton_method('name') do
        name
      end

      linter.define_singleton_method('configure') do |options|
        @problem = options['Problem'] if options['Problem']
      end


      linter
    end

    def self.generate_fake_linter_class(module_name: nil, class_name: 'FakeLinter', name: 'Some Name', finds_problems: true)

      if module_name
        parent_module = Kernel.const_defined?(module_name) ? Kernel.const_get(module_name) : Kernel.const_set(module_name, Module.new)
      end

      (parent_module || Kernel).const_set(class_name, Class.new do

        define_method('lint') do |model|
          location = model.respond_to?(:source_line) ? "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" : model.path
          problem  = @problem || "#{name} problem"

          if finds_problems
            { problem:  problem,
              location: location }
          else
            nil
          end
        end

        define_method('name') do
          name
        end

      end)

    end

  end
end
