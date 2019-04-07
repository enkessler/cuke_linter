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

      def create_file(options = {})
        options[:text]      ||= ''
        options[:name]      ||= 'test_file'
        options[:extension] ||= '.txt'
        options[:directory] ||= create_directory

        file_path = "#{options[:directory]}/#{options[:name]}#{options[:extension]}"
        File.write(file_path, options[:text])

        file_path
      end

    end

  end
end
