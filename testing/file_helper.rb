require 'tmpdir'


module CukeLinter
  module FileHelper

    class << self

      def created_directories
        @created_directories ||= []
      end

      def create_directory(options = {})
        options[:name]      ||= 'test_directory'
        options[:directory] ||= Dir.mktmpdir

        path = "#{options[:directory]}/#{options[:name]}"

        Dir::mkdir(path)
        created_directories << options[:directory]

        path
      end

    end

  end
end
