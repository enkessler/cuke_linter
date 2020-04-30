require 'tmpdir'


module CukeLinter

  # A helper module that generates files and directories for use in testing

  module FileHelper

    def self.included(klass)
      klass.include(Methods)
    end

    def self.extended(klass)
      klass.extend(Methods)
    end

    module Methods

      def created_directories
        @created_directories ||= []
      end

      def create_directory(options = {})
        options[:name]      ||= 'test_directory'
        options[:directory] ||= Dir.mktmpdir

        path = "#{options[:directory]}/#{options[:name]}"

        Dir.mkdir(path)
        created_directories << options[:directory]

        path
      end

      def create_file(options = {})
        options[:text]      ||= ''
        options[:name]      ||= 'test_file'
        options[:extension] ||= '.txt'
        options[:directory] ||= create_directory

        file_path = "#{options[:directory]}/#{options[:name]}#{options[:extension]}"
        FileUtils.mkdir_p(File.dirname(file_path)) # Ensuring that the target directory already exists
        File.write(file_path, options[:text])

        file_path
      end

    end

    extend Methods

  end
end
