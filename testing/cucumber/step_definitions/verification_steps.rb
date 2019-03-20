Then(/^a linting report will be made for all features$/) do
  expect(@output).to match(/\d+ issues found/)
end

Then(/^the resulting output is the following:$/) do |text|
  expect(@results).to eq(text)
end

Then(/^an error is reported$/) do |table|
  table.hashes.each do |error_record|
    expect(@results).to include({ linter:   error_record['linter'],
                                  problem:  error_record['problem'],
                                  location: error_record['location'].sub('<path_to_file>', @model.get_ancestor(:feature_file).path) })
  end
end

Then(/^the following linters are registered by default$/) do |linter_names|
  expect(CukeLinter.registered_linters.keys).to match_array(linter_names.raw.flatten)
end
