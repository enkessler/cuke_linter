module CukeLinter
  module DialectHelper
    def self.get_configured_keywords(options, keyword)
      options[keyword] if options[keyword]&.instance_of?(Array)
    end
  end
end
