module CukeLinter
  module DialectHelper

    def self.set_dialect(dialect)
      @dialect = dialect
    end

    def self.given_keyword
      @dialect['given'][1].strip
    end

    def self.when_keyword
      @dialect['when'][1].strip
    end

    def self.then_keyword
      @dialect['then'][1].strip
    end

    def self.get_model_dialect(model)
      set_dialect(Gherkin::DIALECTS[model.parent_model.parsing_data[:language]])
      self
    end
  end
end
