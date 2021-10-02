module CukeLinter

  # A helper module that generates formatters for use in testing
  module FormatterFactory

    module_function

    def generate_fake_formatter(name: 'FakeFormater')
      formatter = Object.new

      formatter.define_singleton_method('format') do |data|
        data.reduce("#{name}: ") do |final, lint_error|
          final << "#{lint_error[:problem]}: #{lint_error[:location]}\n"
        end
      end

      formatter
    end

  end
end
