When(/^the following command is executed:$/) do |command|
  command = "bundle exec ruby #{@executable_directory || "#{PROJECT_ROOT}/exe"}/#{command}"
  command.gsub!('<path_to>', @root_test_directory)

  @results = @output = `#{command}`
end

When(/^it is formatted by the "([^"]*)" formatter$/) do |linter_name|
  @results = CukeLinter.const_get("#{linter_name.capitalize}Formatter").new.format(@linter_data)
end

When(/^(?:the feature|the model|it) is linted$/) do
  options           = { model_trees: [@model],
                        formatters:  [[CukeLinter::FormatterFactory.generate_fake_formatter, "#{CukeLinter::FileHelper::create_directory}/junk_output_file.txt"]] }
  options[:linters] = [@linter] if @linter

  @results = CukeLinter.lint(options)
end

When(/^the configuration file is (?:used|loaded)$/) do
  CukeLinter.load_configuration(config_file_path: @configuration_file_path)
end

And(/^the following code is used:$/) do |code|
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

When(/^"([^"]*)" is the current directory$/) do |directory|
  @working_directory = "#{@root_test_directory}/#{directory}"
end
