Feature: Using cuke_linter on the command line

  Linting functionality can be used directly from the command line.


  Scenario: Linting features

  Note: By default, linting will be done in the current directory using all linters and 'pretty' formatter.

    Given the cuke_linter executable is available
    When the following command is executed:
      """
      cuke_linter
      """
    Then a linting report will be made for all features

  Scenario: Accessing command line help
    Given the cuke_linter executable is available
    When the following command is executed:
      """
      cuke_linter -h
      """
    Then the following help is displayed:
      """
      Usage: cuke_linter [options]
          -h, --help           Display the help that you are reading now.
          -v, --version        Display the version of the gem being used.
      """

  Scenario: Checking the version of CukeLinter
    Given the cuke_linter executable is available
    When the following command is executed:
      """
      cuke_linter -v
      """
    Then the version of the tool is displayed:
      """
      <major>.<minor>.<patch>
      """
