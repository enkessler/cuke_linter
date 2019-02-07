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

  context 'with good data' do

    it 'returns an empty set of results' do
      expect(subject.lint(good_data)).to eq([])
    end

  end

  context 'with bad data' do

    it 'returns a set of detected problems' do
      expect(subject.lint(bad_data)).to_not be_empty
    end

    it 'includes the problems and their locations in its results' do
      results = subject.lint(bad_data)

      results.each { |result| expect(result.keys).to match_array([:problem, :location]) }
    end

  end
end
