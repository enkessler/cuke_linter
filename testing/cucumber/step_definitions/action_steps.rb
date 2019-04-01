When(/^the following command is executed:$/) do |command|
  command = "bundle exec ruby #{@executable_directory}/#{command}"

  @output = `#{command}`
end

When(/^it is formatted by the "([^"]*)" formatter$/) do |linter_name|
  @results = CukeLinter.const_get("#{linter_name.capitalize}Formatter").new.format(@linter_data)
end

When(/^(?:the feature|it) is linted$/) do
  options           = { model_tree: @model,
                        formatters: [[CukeLinter::FormatterFactory.generate_fake_formatter, "#{CukeLinter::FileHelper::create_directory}/junk_output_file.txt"]] }
  options[:linters] = [@linter] if @linter

  @results = CukeLinter.lint(options)
end

When(/^the configuration file is used$/) do
  CukeLinter.load_configuration(config_file_path: @configuration_file_path)
end

And(/^the following code is used:$/) do |code|
  code.sub!('<path_to>', @test_directory)

  eval(code)
end
