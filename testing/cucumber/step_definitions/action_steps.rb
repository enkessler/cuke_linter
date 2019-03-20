When(/^the following command is executed:$/) do |command|
  command = "bundle exec ruby #{@executable_directory}/#{command}"

  @output = `#{command}`
end

When(/^it is formatted by the "([^"]*)" formatter$/) do |linter_name|
  @results = CukeLinter.const_get("#{linter_name.capitalize}Formatter").new.format(@linter_data)
end

When(/^it is linted$/) do
  options = { model_tree: @model,
              linters:    [@linter],
              formatters: [[CukeLinter::FormatterFactory.generate_fake_formatter, "#{CukeLinter::FileHelper::create_directory}/junk_output_file.txt"]] }

  @results = CukeLinter.lint(options)
end
