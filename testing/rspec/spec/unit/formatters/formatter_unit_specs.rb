shared_examples_for 'a formatter at the unit level' do

  it 'can format' do
    expect(subject).to respond_to(:format)
  end

  it 'formats linting data' do
    expect(subject.method(:format).arity).to eq(1)
  end

end
