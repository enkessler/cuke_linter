Then(/^a linting report will be made for all features$/) do
  expect(@output).to match(/\d+ issues found/)
end

Then(/^the resulting output is the following:$/) do |text|
  expect(@results).to eq(text)
end
