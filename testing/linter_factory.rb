module CukeLinter
  module LinterFactory

    def self.generate_fake_linter(name: 'FakeLinter')
      linter = Object.new

      linter.define_singleton_method('lint') do |model|
        location = model.respond_to?(:source_line) ? "#{model.get_ancestor(:feature_file).path}:#{model.source_line}" :
                       model.path
        [{ linter:   name,
           problem:  "#{name} problem",
           location: location }]
      end

      linter
    end

  end
end
