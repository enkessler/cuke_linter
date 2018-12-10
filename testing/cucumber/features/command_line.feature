Feature: Using cuke_linter on the command line

  Linting functionality can be used directly from the command line.


  Scenario: Linting features

    Given the cuke_linter executable is available
    When the following command is executed:
    """
    cuke_linter
    """
    Then a linting report will be made for all features
