module CukeLinter

  # Mix-in module containing methods related to configuring linters
  module Configuration

    # Configures linters based on the given options
    def load_configuration(config_file_path: nil, config: nil)
      # TODO: define what happens if both a configuration file and a configuration are
      # provided. Merge them or have direct config take precedence? Both?

      unless config || config_file_path
        config_file_path = "#{Dir.pwd}/.cuke_linter"
        message          = 'No configuration or configuration file given and no .cuke_linter file found'
        raise message unless File.exist?(config_file_path)
      end

      config ||= YAML.load_file(config_file_path)
      configure_linters(config, registered_linters)
    end


    private


    def configure_linters(configuration, linters) # rubocop:disable Metrics/CyclomaticComplexity - Maybe I'll revisit this later
      common_config = configuration['AllLinters'] || {}
      to_delete     = []

      linters.each_pair do |name, linter|
        linter_config = configuration[name] || {}
        final_config  = common_config.merge(linter_config)

        disabled = (final_config.key?('Enabled') && !final_config['Enabled'])

        # Just save it for afterwards because modifying a collection while iterating through it is not a good idea
        to_delete << name if disabled

        linter.configure(final_config) if linter.respond_to?(:configure)
      end

      to_delete.each { |linter_name| unregister_linter(linter_name) }
    end

  end
end
