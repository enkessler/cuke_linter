Given(/^the cuke_linter executable is available$/) do
  @executable_directory = "#{PROJECT_ROOT}/exe"
end

Given(/^the following linter data:$/) do |linter_data|
  @linter_data = [].tap do |data|
    linter_data.hashes.each do |data_point|
      data << { linter:   data_point['linter name'],
                problem:  data_point['problem'],
                location: data_point['location'] }
    end
  end
end
