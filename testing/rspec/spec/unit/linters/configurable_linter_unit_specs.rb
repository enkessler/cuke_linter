shared_examples_for 'a configurable linter at the unit level' do

  it 'is configurable' do
    expect(subject).to respond_to(:configure)
  end

  it 'is configured via a set of options' do
    expect(subject.method(:configure).arity).to eq(1)
  end

end
