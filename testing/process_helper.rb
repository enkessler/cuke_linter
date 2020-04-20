module CukeLinter
  module ProcessHelper

    class << self

      def create_process(*args)
        args.unshift('cmd.exe', '/c') if ChildProcess.windows?
        ChildProcess.build(*args)
      end

    end
  end
end
