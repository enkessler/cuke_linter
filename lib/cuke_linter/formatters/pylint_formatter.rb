module CukeLinter
  # Formats linting data into the PyLint format
  # path/to/file:line:col: [Rule] Message
  class Pylint8Formatter
    # Formats the given linting data
    def format(data)
      ''.tap do |formatted_data|
        data.each do |problem|
          location = problem[:location].split(":")
          # Linters at the very least don't specify column numbers, but for feature file wide errors
          # there's no line numbers either. Pad the location out if we need to.
          while location.length() < 3
            location.insert(-1, "")
          end
          formatted_data << "#{location.join(separator=':')}: [#{problem[:linter]}] #{problem[:problem]}\n"
        end
      end
    end
  end
end
