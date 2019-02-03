module CukeLinter
  module FormatterFactory

    def self.generate_fake_formatter(name: 'FakeFormater')
      formatter = Object.new

      formatter.define_singleton_method('format') do |data|
        data.reduce("#{name}: ") { |final, lint_error| final << "#{lint_error[:problem]}: #{lint_error[:location]}\n" }
      end

      formatter
    end

  end
end
