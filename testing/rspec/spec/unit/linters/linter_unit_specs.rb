shared_examples_for 'a linter at the unit level' do

  it 'is named' do
    expect(subject).to respond_to(:name)
    expect(subject.name).to be_a_kind_of(String)
    expect(subject.name).to_not be_empty
  end

  it 'can lint' do
    expect(subject).to respond_to(:lint)
  end

  it 'lints a model' do
    expect(subject.method(:lint).arity).to eq(1)
  end

end


shared_examples_for 'a linter linting a good model' do

  it 'returns no problem' do
    expect(subject.lint(test_model)).to be_nil
  end

end


shared_examples_for 'a linter linting a bad model' do

  it 'returns a detected problem' do
    expect(subject.lint(test_model)).to_not be_nil
  end

  it 'includes the problem and its location in its result' do
    result = subject.lint(test_model)

    expect(result).to_not be_nil
    expect(result.keys).to match_array([:problem, :location])
  end

  it 'correctly records the location of the problem' do
    if test_model.is_a?(CukeModeler::FeatureFile)
      result = subject.lint(test_model)
      expect(result[:location]).to eq("#{model_file_path}")
    else
      test_model.source_line = 1
      result                 = subject.lint(test_model)
      expect(result[:location]).to eq("#{model_file_path}:1")

      test_model.source_line = 3
      result                 = subject.lint(test_model)
      expect(result[:location]).to eq("#{model_file_path}:3")
    end
  end

end
