module CukeLinter
  module DialectHelper
    DEFAULT_GIVEN_KEYWORD = 'Given'.freeze
    DEFAULT_WHEN_KEYWORD = 'When'.freeze
    DEFAULT_THEN_KEYWORD = 'Then'.freeze

    def self.get_given_keywords
      @given_keywords || [DEFAULT_GIVEN_KEYWORD]
    end

    def self.get_when_keywords
      @when_keywords || [DEFAULT_WHEN_KEYWORD]
    end

    def self.get_then_keywords
      @then_keywords || [DEFAULT_THEN_KEYWORD]
    end

    def self.set_given_keywords(options)
      @given_keywords ||= get_configured_keywords(options, DEFAULT_GIVEN_KEYWORD)
    end

    def self.set_when_keywords(options)
      @when_keywords ||= get_configured_keywords(options, DEFAULT_WHEN_KEYWORD)
    end

    def self.set_then_keywords(options)
      @then_keywords ||= get_configured_keywords(options, DEFAULT_THEN_KEYWORD)
    end

    def self.get_configured_keywords(options, keyword)
      options[keyword] if options[keyword]&.instance_of?(Array)
    end
  end
end
