# A custom test linter class with no changes from the default linter
class CustomLinter < CukeLinter::Linter; end

# A custom test linter class with a custom #name method
class CustomLinterWithNameMethod < CukeLinter::Linter

  def name
    'Method name'
  end

end


RSpec.describe CukeLinter::Linter do

  let(:model_file_path) { 'some_file_path' }

  let(:linter_name) { 'FooLinter' }
  let(:linter_message) { 'Foo!' }
  let(:linter_rule) { ->(model) { !model.is_a?(CukeModeler::Example) } }
  let(:linter_options) { { name: linter_name, message: linter_message, rule: linter_rule } }

  let(:good_data) { generate_example_model }
  let(:bad_data) { generate_outline_model }


  it_should_behave_like 'a linter at the unit level'

  context 'with a linting rule' do

    subject { CukeLinter::Linter.new(**linter_options, rule: linter_rule) }

    context 'with a good model' do

      let(:test_model) { generate_example_model }

      it_should_behave_like 'a linter linting a good model'

    end

    context 'with a bad model' do

      let(:test_model) { generate_outline_model(parent_file_path: model_file_path) }

      it_should_behave_like 'a linter linting a bad model'

    end

  end


  context 'with custom values' do

    subject { CukeLinter::Linter.new(**linter_options) }

    it 'uses the provided name' do
      expect(subject.name).to eq(linter_name)
    end

    it 'uses the provided rule' do
      expect(subject.lint(good_data)).to be_nil
      expect(subject.lint(bad_data)).to_not be_nil
    end

    it 'uses the provided message' do
      result = subject.lint(bad_data)

      expect(result[:problem]).to eq(linter_message)
    end

  end

  context 'with custom methods' do

    subject do
      linter = CukeLinter::Linter.new

      linter.define_singleton_method('rule') do |model|
        !model.is_a?(CukeModeler::Example)
      end

      linter.define_singleton_method('name') do
        'FooLinter'
      end

      linter.define_singleton_method('message') do
        'Foo!'
      end

      linter
    end


    it 'uses the provided #name' do
      expect(subject.name).to eq(linter_name)
    end

    it 'uses the provided #rule' do
      expect(subject.lint(good_data)).to be_nil
      expect(subject.lint(bad_data)).to_not be_nil
    end

    it 'uses the provided #message' do
      result = subject.lint(bad_data)

      expect(result[:problem]).to eq(linter_message)
    end

  end

  context 'with both custom values and methods' do

    let(:good_data) do
      generate_outline_model
    end

    let(:bad_data) do
      generate_example_model
    end

    subject do
      linter = CukeLinter::Linter.new(**linter_options)

      linter.define_singleton_method('rule') do |model|
        model.is_a?(CukeModeler::Example)
      end

      linter.define_singleton_method('name') do
        'Method Linter'
      end

      linter.define_singleton_method('message') do
        'Method Foo!'
      end

      linter
    end


    it 'uses #name instead of the provided name' do
      expect(subject.name).to eq('Method Linter')
    end

    it 'uses #rule instead of the provided rule' do
      expect(subject.lint(good_data)).to be_nil
      expect(subject.lint(bad_data)).to_not be_nil
    end

    it 'uses #message instead of the provided message' do
      result = subject.lint(bad_data)

      expect(result[:problem]).to eq('Method Foo!')
    end

  end

  context 'with neither custom values nor methods' do

    subject { CukeLinter::Linter.new }


    it 'complains if not provided with a rule' do
      expect { subject.lint('Anything') }.to raise_error('No linting rule provided!')
    end


    it 'has a default name based on its class' do
      expect(subject.name).to eq('Linter')

      expect(CustomLinter.new.name).to eq('CustomLinter')
    end

    it 'has a default message based on its name' do
      linter_options[:message] = nil

      # Default name
      linter_options[:name] = nil
      linter                = CukeLinter::Linter.new(**linter_options)
      result                = linter.lint(bad_data)

      expect(result[:problem]).to eq('Linter problem detected')

      # Value name
      linter_options[:name] = 'Value name'
      linter                = CukeLinter::Linter.new(**linter_options)
      result                = linter.lint(bad_data)

      expect(result[:problem]).to eq('Value name problem detected')

      # Method name
      linter_options[:name] = nil
      linter                = CustomLinterWithNameMethod.new(**linter_options)
      result                = linter.lint(bad_data)

      expect(result[:problem]).to eq('Method name problem detected')
    end

  end

end
