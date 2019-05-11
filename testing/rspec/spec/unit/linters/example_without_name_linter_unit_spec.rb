require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::ExampleWithoutNameLinter do

  let(:good_data) do
    model      = CukeLinter::ModelFactory.generate_example_model
    model.name = 'foo'

    model
  end

  let(:bad_data) do
    model      = CukeLinter::ModelFactory.generate_example_model
    model.name = ''

    model
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('ExampleWithoutNameLinter')
  end

  describe 'linting' do

    context 'an example with no name' do

      let(:test_model_with_nil_name) do
        model      = CukeLinter::ModelFactory.generate_example_model(parent_file_path: 'path_to_file')
        model.name = nil

        model
      end

      let(:test_model_with_blank_name) do
        model      = CukeLinter::ModelFactory.generate_example_model(parent_file_path: 'path_to_file')
        model.name = ''

        model
      end

      it 'records a problem' do
        result = subject.lint(test_model_with_nil_name)

        expect(result[:problem]).to eq('Example has no name')

        result = subject.lint(test_model_with_blank_name)

        expect(result[:problem]).to eq('Example has no name')
      end

      it 'records the location of the problem' do
        model_1             = CukeLinter::ModelFactory.generate_example_model(parent_file_path: 'path_to_file')
        model_1.name        = nil
        model_1.source_line = 1
        model_2             = CukeLinter::ModelFactory.generate_example_model(parent_file_path: 'path_to_file')
        model_2.name        = nil
        model_2.source_line = 3

        result = subject.lint(model_1)
        expect(result[:location]).to eq('path_to_file:1')

        result = subject.lint(model_2)
        expect(result[:location]).to eq('path_to_file:3')
      end

    end

    context 'a non-example model' do

      it 'returns no result' do
        result = subject.lint(CukeModeler::Model.new)

        expect(result).to eq(nil)
      end

    end
  end
end
