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

    it 'returns no problem' do
      expect(subject.lint(good_data)).to be_nil
    end

  end

  context 'with bad data' do

    it 'returns a detected problems' do
      expect(subject.lint(bad_data)).to_not be_nil
    end

    it 'includes the problem and its locations in its result' do
      result = subject.lint(bad_data)

      expect(result.keys).to match_array([:problem, :location])
    end

  end
end
