module CukeLinter

  # A helper module that generates linters for use in testing

  module LinterFactory

    def self.included(klass)
      klass.include(Methods)
    end

    def self.extended(klass)
      klass.extend(Methods)
    end

    module Methods

      def generate_fake_linter(name: 'FakeLinter', finds_problems: true)
        linter = Object.new

        linter.define_singleton_method('lint') do |model|
          location = if model.respond_to?(:source_line)
                       "#{model.get_ancestor(:feature_file).path}:#{model.source_line}"
                     else
                       model.path
                     end
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

            if finds_problems
              { problem:  problem,
                location: location }
            else
              nil
            end
          end

          define_method('name') do
            linter_name
          end

        end)

      end

    end

    extend Methods

  end
end
