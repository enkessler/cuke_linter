Feature: Using a configuration

  Configuration can be done during a script or through a configuration file. This file can be explicitly
  provided or a default configuration file will be used.


  Scenario: Providing a configuration directly
    Given a linter registered as "SomeLinter"
    When the following code is used:
      """
      CukeLinter.load_configuration(config: { 'SomeLinter' => { 'Enabled' => false } })
      """
    Then the linter "SomeLinter" is no longer registered

  Scenario: Loading a configuration from a file
    Given a linter registered as "SomeLinter"
    And the following configuration file "my_config.file":
      """
      SomeLinter:
        Enabled: false
      """
    When the following code is used:
      """
      CukeLinter.load_configuration(config_file_path: '<path_to>/my_config.file')
      """
    Then the linter "SomeLinter" is no longer registered

  Scenario: Using the default configuration file
    Given a directory "test_directory"
    And the following configuration file "test_directory/.cuke_linter":
      """
      SomeLinter:
        Enabled: false
      """
    And a linter registered as "SomeLinter"
    When "test_directory" is the current directory
    And the following code is used:
      """
      CukeLinter.load_configuration
      """
    Then the linter "SomeLinter" is no longer registered
