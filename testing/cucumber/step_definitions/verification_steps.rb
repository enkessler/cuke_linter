Then(/^a linting report will be made for all features$/) do
  expect(@output).to match(/\d+ issues found/)
end
