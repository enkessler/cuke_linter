require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::Linter do

  let(:linter_name) { 'FooLinter' }
  let(:linter_message) { 'Foo!' }
  let(:linter_rule) { lambda { |model| !model.is_a?(CukeModeler::Example) } }
  let(:linter_options) { { name: linter_name, message: linter_message, rule: linter_rule } }

  let(:good_data) do
    CukeLinter::ModelFactory.generate_example_model
  end

  let(:bad_data) do
    CukeLinter::ModelFactory.generate_outline_model
  end


  context 'with custom values' do

    subject { CukeLinter::Linter.new(linter_options) }


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

  context 'with custom methods' do

    subject { linter = CukeLinter::Linter.new

              linter.define_singleton_method('rule') do |model|
                !model.is_a?(CukeModeler::Example)
              end

              linter.define_singleton_method('name') do
                'FooLinter'
              end

              linter.define_singleton_method('message') do
                'Foo!'
              end


              linter }


    it_should_behave_like 'a linter at the unit level'

    it 'uses the provided #name' do
      expect(subject.name).to eq(linter_name)
    end

    it 'uses the provided #rule' do
      expect(subject.lint(good_data)).to be_empty
      expect(subject.lint(bad_data)).to_not be_empty
    end

    it 'uses the provided #message' do
      results = subject.lint(bad_data)

      expect(results.first[:problem]).to eq(linter_message)
    end

  end

  context 'with both custom values and methods' do

    let(:good_data) do
      CukeLinter::ModelFactory.generate_outline_model
    end

    let(:bad_data) do
      CukeLinter::ModelFactory.generate_example_model
    end

    subject { linter = CukeLinter::Linter.new(linter_options)

              linter.define_singleton_method('rule') do |model|
                model.is_a?(CukeModeler::Example)
              end

              linter.define_singleton_method('name') do
                'Method Linter'
              end

              linter.define_singleton_method('message') do
                'Method Foo!'
              end


              linter }


    it 'uses #name instead of the provided name' do
      expect(subject.name).to eq('Method Linter')
    end

    it 'uses #rule instead of the provided rule' do
      expect(subject.lint(good_data)).to be_empty
      expect(subject.lint(bad_data)).to_not be_empty
    end

    it 'uses #message instead of the provided message' do
      results = subject.lint(bad_data)

      expect(results.first[:problem]).to eq('Method Foo!')
    end

  end

  context 'with neither custom values nor methods' do

    subject { CukeLinter::Linter.new }


    it 'complains if not provided with a rule' do
      expect { subject.lint('Anything') }.to raise_error('No linting rule provided!')
    end


    it 'has a default name based on its class' do
      expect(subject.name).to eq('Linter')

      class CustomLinter < CukeLinter::Linter;
      end

      expect(CustomLinter.new.name).to eq('CustomLinter')
    end

    it 'has a default message based on its name' do
      linter_options[:message] = nil

      # Default name
      linter_options[:name] = nil
      linter                = CukeLinter::Linter.new(linter_options)
      results               = linter.lint(bad_data)

      expect(results.first[:problem]).to eq('Linter problem detected')

      # Value name
      linter_options[:name] = 'Value name'
      linter                = CukeLinter::Linter.new(linter_options)
      results               = linter.lint(bad_data)

      expect(results.first[:problem]).to eq('Value name problem detected')

      # Method name
      class CustomLinter < CukeLinter::Linter;
        def name
          'Method name'
        end
      end

      linter_options[:name] = nil
      linter                = CustomLinter.new(linter_options)
      results               = linter.lint(bad_data)

      expect(results.first[:problem]).to eq('Method name problem detected')
    end

  end

end
