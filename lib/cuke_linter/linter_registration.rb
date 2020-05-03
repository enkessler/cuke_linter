module CukeLinter

  # Mix-in module containing methods related to registering linters
  module LinterRegistration

    # Returns the registered linters to their default state
    def reset_linters
      @registered_linters = nil
    end

    # Registers for linting use the given linter object, tracked by the given name
    def register_linter(linter:, name:)
      registered_linters[name] = linter
    end

    # Unregisters the linter object tracked by the given name so that it is not used for linting
    def unregister_linter(name)
      registered_linters.delete(name)
    end

    # Lists the names of the currently registered linting objects
    def registered_linters
      @registered_linters ||= Marshal.load(Marshal.dump(@original_linters))
    end

    # Unregisters all currently registered linting objects
    def clear_registered_linters
      registered_linters.clear
    end

  end
end
