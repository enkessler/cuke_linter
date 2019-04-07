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

Given(/^no other linters have been registered or unregistered$/) do
  CukeLinter.reset_linters
end

Given(/^a linter for examples without names$/) do
  @linter = CukeLinter::ExampleWithoutNameLinter.new
end

Given(/^a linter for outlines with only one example row$/) do
  @linter = CukeLinter::OutlineWithSingleExampleRowLinter.new
end

Given(/^a linter for tests with too many steps$/) do
  @linter = CukeLinter::TestWithTooManyStepsLinter.new
end

Given(/^a linter for tests with too many steps has been registered$/) do
  CukeLinter.register_linter(linter: CukeLinter::TestWithTooManyStepsLinter.new, name: 'TestWithTooManyStepsLinter')
end

Given(/^the following configuration file(?: "([^"]*)")?:$/) do |file_name, text|
  file_name ||= '.cuke_linter'

  @configuration_file_path = CukeLinter::FileHelper.create_file(directory: @root_test_directory, name: file_name, extension: '', text: text)
end

Given(/^a linter "([^"]*)"$/) do |linter_class|
  @linter = CukeLinter.const_get(linter_class).new
end

Given(/^a linter registered as "([^"]*)"$/) do |linter_name|
  CukeLinter.register_linter(linter: CukeLinter::LinterFactory.generate_fake_linter(name: linter_name), name: linter_name)
end

Given(/^a directory "([^"]*)"$/) do |directory_name|
  @test_directory = CukeLinter::FileHelper.create_directory(directory: @root_test_directory, name: directory_name)
end
