module CukeLinter

  # Some helper methods used during testing
  module HelperMethods

    def cuke_modeler?(versions)
      versions = [versions] unless versions.is_a?(Enumerable)
      versions.include?(cuke_modeler_major_version)
    end

    def cuke_modeler_major_version
      Gem.loaded_specs['cuke_modeler'].version.version.match(/^(\d+)\./)[1].to_i
    end

  end
end
