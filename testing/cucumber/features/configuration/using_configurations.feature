Feature: Using a configuration


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


  @wip
  Scenario: Using the default configuration file
