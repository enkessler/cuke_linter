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
          -p, --path PATH                The file path that should be linted. Can be a file or directory.
                                         This option can be specified multiple times in order to lint
                                         multiple, unconnected locations.
          -r, --require FILEPATH         A file that will be required before further processing. Likely
                                         needed when using custom linters or formatters in order to ensure
                                         that the specified classes have been read into memory. This option
                                         can be specified multiple times in order to load more than one file.
          -h, --help                     Display the help that you are reading now.
          -v, --version                  Display the version of the gem being used.
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

  Scenario: Specifying directories and files to lint
    Given the following feature file "some.feature":
      """
      Feature:
        Scenario: A scenario
          * a step
      """
    And the following feature file "a_directory/with_a.feature":
      """
      Feature:
        Scenario: A scenario
          * a step
      """
    When the following command is executed:
      """
      cuke_linter -p <path_to>/some.feature -p <path_to>/a_directory
      """
    Then the resulting output is the following:
      """
      FeatureWithoutDescriptionLinter
        Feature has no description
          <path_to>/a_directory/with_a.feature:1
          <path_to>/some.feature:1

      2 issues found
      """

  Scenario: Loading additional files
    Given the following file "some_important_file.rb":
      """
      puts 'I got loaded!'
      """
    When the following command is executed:
      """
      cuke_linter -r <path_to>/some_important_file.rb
      """
    Then the resulting output will include the following:
      """
      I got loaded!
      """
