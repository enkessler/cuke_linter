Feature: Custom linters

  In addition to the linters provided by CukeLinter, custom linters can be used. A linter is essentially any object that provides a few needed methods. In order to simplify the creation of custom linters, a base linter class is available that provides these needed methods.


  Scenario: Creating a custom linter object
    Given the following custom linter object:
      """
      custom_name    = 'MyCustomLinter'
      custom_message = 'My custom message'
      custom_rule    = lambda do |model|
                         # Your logic here, return true for a problem and false for not problem
                         true
                       end

      @linter = CukeLinter::Linter.new(name: custom_name,
                                       message: custom_message,
                                       rule: custom_rule)
      """
    And a model to lint
    When the model is linted
    Then an error is reported
      | linter         | problem           | location                           |
      | MyCustomLinter | My custom message | <path_to_file>:<model_line_number> |

  Scenario: Creating a custom linter class
    Given the following custom linter class:
      """
      class MyCustomLinter < CukeLinter::Linter

        def name
          'MyCustomLinter'
        end

        def message
          'My custom message'
        end

        def rule(model)
          # Your logic here, return true for a problem and false for not problem
          true
        end

      end
      """
    And the following code is used:
      """
      @linter = MyCustomLinter.new
      """
    And a model to lint
    When the model is linted
    Then an error is reported
      | linter         | problem           | location                           |
      | MyCustomLinter | My custom message | <path_to_file>:<model_line_number> |
