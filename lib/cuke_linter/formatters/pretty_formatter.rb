module CukeLinter

  # Formats linting data into organized, user readable text

  class PrettyFormatter

    # Formats the given linting data
    def format(data)
      categorized_problems = Hash.new { |linters, linter_name| linters[linter_name] = Hash.new { |problems, problem| problems[problem] = [] } }

      data.each do |lint_item|
        categorized_problems[lint_item[:linter]][lint_item[:problem]] << lint_item[:location]
      end

      formatted_data = ''

      categorized_problems.each_pair do |linter, problems|
        formatted_data << linter + "\n"

        problems.each_pair do |problem, locations|
          formatted_data << "  #{problem}" + "\n"

          sorted_locations = locations.sort do |a, b|
            file_name_1   = a.match(/(.*?)(?::\d+)?$/)[1]
            line_number_1 = a.match(/:(\d+)$/) ? a.match(/:(\d+)$/)[1].to_i : 0
            file_name_2   = b.match(/(.*?)(?::\d+)?$/)[1]
            line_number_2 = b.match(/:(\d+)$/) ? b.match(/:(\d+)$/)[1].to_i : 0

            case
              when (file_name_1 < file_name_2) ||
                  (file_name_1 == file_name_2) && (line_number_1 < line_number_2)
                -1
              when (file_name_1 > file_name_2) ||
                  (file_name_1 == file_name_2) && (line_number_1 > line_number_2)
                1
              else
                0
            end
          end

          sorted_locations.each do |location|
            formatted_data << "    #{location}\n"
          end
        end
      end

      total_problems = data.count
      formatted_data << "\n" unless total_problems.zero?

      formatted_data << "#{total_problems} issues found"

      formatted_data
    end

  end
end
