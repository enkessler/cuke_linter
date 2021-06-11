require 'childprocess'

module CukeLinter

  # Various helper methods for the project
  module CukeLinterHelper

    module_function


    def run_command(parts, env_vars: {}, pipe_output: true)
      create_process(parts, env_vars: env_vars, run: true, pipe_output: pipe_output)
    end

    def create_process(parts, env_vars: {}, run: false, pipe_output: true)
      parts.unshift('cmd.exe', '/c') if ChildProcess.windows?
      process = ChildProcess.build(*parts)

      env_vars.each_pair { |variable_name, value| process.environment[variable_name.to_s] = value }

      process.io.inherit! if pipe_output

      if run
        process.start
        process.wait
      end

      process
    end

    def rspec_test_file_pattern
      "testing/rspec/spec/**/*_spec.rb"
    end

  end
end
