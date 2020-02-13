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

Given(/^a linter for features with invalid file names$/) do
  @linter = CukeLinter::FeatureFileWithInvalidNameLinter.new
end

And(/^a linter for features with mismatched file names$/) do
  @linter = CukeLinter::FeatureFileWithMismatchedNameLinter.new
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

Given("a linter for tests with bad names") do
  @linter = CukeLinter::TestWithBadNameLinter.new
end

Given(/^a linter for tests with too many steps$/) do
  @linter = CukeLinter::TestWithTooManyStepsLinter.new
end

Given(/^a linter for steps the end with a period$/) do
  @linter = CukeLinter::StepWithEndPeriodLinter.new
end

Given(/^a linter for backgrounds applied to only one test$/) do
  @linter = CukeLinter::SingleTestBackgroundLinter.new
end

Given(/^a linter for backgrounds that do more than setup$/) do
  @linter = CukeLinter::BackgroundDoesMoreThanSetupLinter.new
end

Given("a linter for test steps with too many characters") do
  @linter = CukeLinter::StepWithTooManyCharactersLinter.new
end

Given(/^a linter for tests with no action step$/) do
  @linter = CukeLinter::TestWithNoActionStepLinter.new
end

Given(/^a linter for tests with no verification step$/) do
  @linter = CukeLinter::TestWithNoVerificationStepLinter.new
end

Given(/^a linter for features without a name$/) do
  @linter = CukeLinter::FeatureWithoutNameLinter.new
end

Given(/^a linter for elements with too many tags$/) do
  @linter = CukeLinter::ElementWithTooManyTagsLinter.new
end

Given(/^a linter for features with too many different tags$/) do
  @linter = CukeLinter::FeatureWithTooManyDifferentTagsLinter.new
end

Given(/^a linter for elements with too many tags has been registered$/) do
  CukeLinter.register_linter(linter: CukeLinter::ElementWithTooManyTagsLinter.new, name: 'ElementWithTooManyTagsLinter')
end

Given(/^a linter for elements with duplicate tags has been registered$/) do
  CukeLinter.register_linter(linter: CukeLinter::ElementWithDuplicateTagsLinter.new, name: 'ElementWithDuplicateTagsLinter')
end

Given(/^a linter for tests with too many steps has been registered$/) do
  CukeLinter.register_linter(linter: CukeLinter::TestWithTooManyStepsLinter.new, name: 'TestWithTooManyStepsLinter')
end

Given("a linter for features without a description") do
  @linter = CukeLinter::FeatureWithoutDescriptionLinter.new
end

Given(/^a linter for tests with no name$/) do
  @linter = CukeLinter::TestWithNoNameLinter.new
end

Given(/^a linter for tests that should use a background$/) do
  @linter = CukeLinter::TestShouldUseBackgroundLinter.new
end

Given(/^a linter for tests with a setup step after an action step$/) do
  @linter = CukeLinter::TestWithSetupStepAfterActionStepLinter.new
end

Given(/^a linter for tests with a setup step after a verification step$/) do
  @linter = CukeLinter::TestWithSetupStepAfterVerificationStepLinter.new
end

Given(/^a linter for tests with a setup step as the final step$/) do
  @linter = CukeLinter::TestWithSetupStepAsFinalStepLinter.new
end

Given(/^a linter for tests with an action step as the final step$/) do
  @linter = CukeLinter::TestWithActionStepAsFinalStepLinter.new
end

Given(/^a linter for elements with duplicate tags$/) do
  @linter = CukeLinter::ElementWithDuplicateTagsLinter.new
end

Given(/^a linter for elements with common tags$/) do
  @linter = CukeLinter::ElementWithCommonTagsLinter.new
end

Given(/^a linter for test steps with too many characters has been registered$/) do
  CukeLinter.register_linter(linter: CukeLinter::StepWithTooManyCharactersLinter.new, name: 'StepWithTooManyCharactersLinter')
end

Given(/^a linter for features with too many different tags has been registered$/) do
  CukeLinter.register_linter(linter: CukeLinter::FeatureWithTooManyDifferentTagsLinter.new, name: 'FeatureWithTooManyDifferentTagsLinter')
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

Given(/^no linters are currently registered$/) do
  CukeLinter.clear_registered_linters
end

Given(/^the following custom linter object:$/) do |code|
  code.sub!('<path_to>', @root_test_directory)
  code.sub!('<code_to_generate_a_new_linter_instance>', 'CukeLinter::LinterFactory.generate_fake_linter')

  if @working_directory
    Dir.chdir(@working_directory) do
      eval(code)
    end
  else
    eval(code)
  end
end

And(/^a model to lint$/) do
  # Any old model should be fine
  @model = CukeModeler::Feature.new

  fake_file_model      = CukeModeler::FeatureFile.new
  fake_file_model.path = 'path_to_file'

  @model.parent_model = fake_file_model
end

Given(/^the following custom linter class:$/) do |code|
  eval(code)
end

Given(/^the following(?: feature)? file "([^"]*)":$/) do |file_path, text|
  path, extension = file_path.split('.')

  @created_files ||= []
  @created_files << CukeLinter::FileHelper.create_file(directory: @root_test_directory, name: path, extension: ".#{extension}", text: text)
end

Given(/^the default linters are being used$/) do
  CukeLinter.reset_linters
end

And(/^a feature file model based on the following text:$/) do |text|
  file_path = CukeLinter::FileHelper.create_file(directory: @root_test_directory, extension: '.feature', text: text)

  @created_files ||= []
  @created_files << file_path

  @model = CukeModeler::FeatureFile.new(file_path)
end

Given(/^a feature file model named "([^"]*)"$/) do |file_path|
  @model = CukeModeler::FeatureFile.new

  @model.path = file_path
end

Given(/^a feature file model based on the file "([^"]*)" with the following text:$/) do |file_name, text|
  file_path = CukeLinter::FileHelper.create_file(directory: @root_test_directory, extension: '.feature', text: text, name: file_name)

  @created_files ||= []
  @created_files << file_path

  @model = CukeModeler::FeatureFile.new(file_path)
end
