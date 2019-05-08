require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::Linter do

  it 'complains if not provided with a name' do
    expect { CukeLinter::Linter.new(message: 'foo', rule: 'foo') }.to raise_error(ArgumentError, /name/)
  end

  it 'complains if not provided with a message' do
    expect { CukeLinter::Linter.new(name: 'foo', rule: 'foo') }.to raise_error(ArgumentError, /message/)
  end

  it 'complains if not provided with a rule' do
    expect { CukeLinter::Linter.new(name: 'foo', message: 'foo') }.to raise_error(ArgumentError, /rule/)
  end


  context 'with custom values' do

    let(:linter_name) { 'FooLinter' }
    let(:linter_message) { 'Foo!' }
    let(:linter_rule) { lambda { |model| !model.is_a?(CukeModeler::Example) } }

    subject { CukeLinter::Linter.new(name: linter_name, message: linter_message, rule: linter_rule) }

    let(:good_data) do
      CukeLinter::ModelFactory.generate_example_model
    end

    let(:bad_data) do
      CukeLinter::ModelFactory.generate_outline_model
    end


    it_should_behave_like 'a linter at the unit level'


    it 'uses the provided name' do
      expect(subject.name).to eq(linter_name)
    end

    it 'uses the provided rule' do
      expect(subject.lint(good_data)).to be_empty
      expect(subject.lint(bad_data)).to_not be_empty
    end

    it 'uses the provided message' do
      results = subject.lint(bad_data)

      expect(results.first[:problem]).to eq(linter_message)
    end

  end

end
