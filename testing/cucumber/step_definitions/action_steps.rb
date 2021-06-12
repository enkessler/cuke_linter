When(/^the following command is executed:$/) do |command|
  command = "bundle exec ruby #{@executable_directory || "#{PROJECT_ROOT}/exe"}/#{command}"
  command.gsub!('<path_to>', @root_test_directory)

  Dir.chdir(@root_test_directory) do
    @results = @output = `#{command}`
  end
end

When(/^it is formatted by the "([^"]*)" formatter$/) do |linter_name|
  @results = CukeLinter.const_get("#{linter_name.capitalize}Formatter").new.format(@linter_data)
end

When(/^(?:the feature|the model|it) is linted$/) do
  options           = { model_trees: [@model],
                        formatters:  [[generate_fake_formatter, "#{create_directory}/junk_output_file.txt"]] }
  options[:linters] = [@linter] if @linter

  @results = CukeLinter.lint(**options)
end

When(/^the configuration file is (?:used|loaded)$/) do
  CukeLinter.load_configuration(config_file_path: @configuration_file_path)
end

And(/^the following code is used:$/) do |code|
  code.sub!('<path_to>', @root_test_directory)
  code.sub!('<code_to_generate_a_new_linter_instance>', 'generate_fake_linter')

  if @working_directory
    Dir.chdir(@working_directory) do
      eval(code)
    end
  else
    eval(code)
  end
end

When(/^"([^"]*)" is the current directory$/) do |directory|
  @working_directory = "#{@root_test_directory}/#{directory}"
end

When(/^the executable finds no linting problems$/) do
  # Linting an empty directory doesn't (currently) find any problems
  command = "bundle exec ruby #{PROJECT_ROOT}/exe/cuke_linter"

  std_out = std_err = status = nil

  Dir.chdir(@root_test_directory) do
    std_out, std_err, status = Open3.capture3(command)
  end

  @results = { std_out: std_out, std_err: std_err, status: status }
end

When(/^the executable finds linting problems$/) do
  # This should be a problematic feature file
  create_file(directory: @root_test_directory,
              name:      'pretty_empty',
              extension: '.feature',
              text:      'Feature: ')


  command = "bundle exec ruby #{PROJECT_ROOT}/exe/cuke_linter"

  std_out = std_err = status = nil

  Dir.chdir(@root_test_directory) do
    std_out, std_err, status = Open3.capture3(command)
  end

  @results = { std_out: std_out, std_err: std_err, status: status }
end

When(/^the executable has a problem$/) do
  # Missing a required argument for a flag should be a problem
  command = "bundle exec ruby #{PROJECT_ROOT}/exe/cuke_linter -r"

  std_out = std_err = status = nil

  Dir.chdir(@root_test_directory) do
    std_out, std_err, status = Open3.capture3(command)
  end

  @results = { std_out: std_out, std_err: std_err, status: status }
end
