module CukeLinter

  # Formats linting data into organized, user readable text
  class PrettyFormatter

    # Formats the given linting data
    def format(data)
      format_data(categorize_problems(data), data.count)
    end


    private


    def categorize_problems(data)
      {}.tap do |categorized_problems|
        data.each do |lint_item|
          categorized_problems[lint_item[:linter]]                      ||= {}
          categorized_problems[lint_item[:linter]][lint_item[:problem]] ||= []
          categorized_problems[lint_item[:linter]][lint_item[:problem]] << lint_item[:location]
        end
      end
    end

    def format_data(problem_data, problem_count)
      ''.tap do |formatted_data|
        problem_data.each_pair do |linter, problems|
          formatted_data << "#{linter}\n"

          problems.each_pair do |problem, locations|
            formatted_data << "  #{problem}\n"

            sort_locations(locations).each do |location|
              formatted_data << "    #{location}\n"
            end
          end
        end

        formatted_data << "\n" unless problem_count.zero?
        formatted_data << "#{problem_count} issues found"
      end
    end

    def sort_locations(locations)
      locations.sort do |a, b|
        file_name_1   = a.match(/(.*?)(?::\d+)?$/)[1]
        line_number_1 = a =~ /:\d+$/ ? a.match(/:(\d+)$/)[1].to_i : 0
        file_name_2   = b.match(/(.*?)(?::\d+)?$/)[1]
        line_number_2 = b =~ /:\d+$/ ? b.match(/:(\d+)$/)[1].to_i : 0

        compare_locations(file_name_1, file_name_2, line_number_1, line_number_2)
      end
    end

    def compare_locations(file_name_1, file_name_2, line_number_1, line_number_2)
      if (file_name_1 < file_name_2) || (file_name_1 == file_name_2) && (line_number_1 < line_number_2)
        -1
      elsif (file_name_1 > file_name_2) || (file_name_1 == file_name_2) && (line_number_1 > line_number_2)
        1
      else
        0
      end
    end

  end
end
