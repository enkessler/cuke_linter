module CukeLinter

  # A helper module that generates new processes for use in testing

  module ProcessHelper

    def self.included(klass)
      klass.include(Methods)
    end

    def self.extended(klass)
      klass.extend(Methods)
    end

    module Methods

      def create_process(*args)
        args.unshift('cmd.exe', '/c') if ChildProcess.windows?
        ChildProcess.build(*args)
      end

    end

    extend Methods

  end
end
