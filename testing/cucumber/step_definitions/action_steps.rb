When(/^the following command is executed:$/) do |command|
  command = "bundle exec ruby #{@executable_directory}/#{command}"

  @output = `#{command}`
end
