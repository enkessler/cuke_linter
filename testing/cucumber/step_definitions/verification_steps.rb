Then(/^a linting report will be made for all features$/) do
  expect(@output).to match(/\d+ issues found/)
end

Then(/^the resulting output is the following:$/) do |text|
  text.gsub!('<path_to>', @root_test_directory)

  expect(@results.strip).to eq(text)
end

Then(/^the resulting output will include the following:$/) do |text|
  text.gsub!('<path_to>', @root_test_directory)

  expect(@results.chomp).to include(text)
end

Then(/^an error is reported:$/) do |table|
  if @model.is_a?(CukeModeler::FeatureFile)
    model_path        = @model.path
    model_source_line = ''
  else
    model_path        = @model.get_ancestor(:feature_file).path
    model_source_line = @model.source_line.to_s
  end

  table.hashes.each do |error_record|
    expect(@results).to include({ linter:   error_record['linter'],
                                  problem:  error_record['problem'],
                                  location: error_record['location']
                                              .sub('<path_to_file>', model_path)
                                              .sub('<model_line_number>', model_source_line) })
  end
end

Then(/^the following problems are( not)? reported:$/) do |exclude, table|
  assertion_method = exclude ? :to_not : :to

  if @model.is_a?(CukeModeler::FeatureFile)
    feature_file_model = @model
    source_line        = ''
  else
    feature_file_model = @model.get_ancestor(:feature_file)
    source_line        = @model.source_line.to_s
  end

  table.hashes.each do |error_record|
    expect(@results).send(assertion_method, include({ linter:   error_record['linter'],
                                                      problem:  error_record['problem'],
                                                      location: error_record['location']
                                                                  .sub('<path_to_file>', feature_file_model.path)
                                                                  .sub('<model_line_number>', source_line) }))
  end
end

Then(/^the following linters are registered(?: by default)?$/) do |linter_names|
  expect(CukeLinter.registered_linters.keys).to match_array(linter_names.raw.flatten)
end

Then(/^an error is reported$/) do
  expect(@results).to_not be_empty
end

Then(/^no error is reported$/) do
  expect(@results).to be_empty
end

Then(/^the linter "([^"]*)" is no longer registered$/) do |linter_name|
  expect(CukeLinter.registered_linters).to_not have_key(linter_name)
end

Then(/^the following help is displayed:$/) do |text|
  expect(@output.chomp).to eq(text)
end

Then(/^the version of the tool is displayed:$/) do |text|
  major_number, minor_number, patch_number = CukeLinter::VERSION.split('.')
  text.sub!('<major>', major_number)
  text.sub!('<minor>', minor_number)
  text.sub!('<patch>', patch_number)

  expect(@output.chomp).to eq(text)
end

Then(/^the linting report will be output to "([^"]*)"$/) do |file_path|
  file_path.gsub!('<path_to>', @root_test_directory)

  expect(File.read(file_path)).to match(/\d+ issues found/)
end

And(/^the file "([^"]*)" contains:$/) do |file_path, text|
  file_path.gsub!('<path_to>', @root_test_directory)

  expect(File.read(file_path)).to eq(text)
end

Then(/^the exit code is "([^"]*)"$/) do |exit_code|
  expect(@results[:status].exitstatus).to eq(exit_code.to_i)
end
