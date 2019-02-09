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

Given(/^the following feature:$/) do |text|
  @model = CukeModeler::Feature.new(text)

  fake_file_model      = CukeModeler::FeatureFile.new
  fake_file_model.path = 'path_to_file'

  @model.parent_model = fake_file_model
end

Given(/^a linter for features without scenarios$/) do
  @linter = CukeLinter::FeatureWithoutScenariosLinter.new
end

Given(/^no other linters have been registered$/) do
  # There is no way to 'reset' the linters, so just assume that no changes have been made
end
