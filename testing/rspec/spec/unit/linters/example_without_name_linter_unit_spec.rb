require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::ExampleWithoutNameLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('ExampleWithoutNameLinter')
  end

  describe 'linting' do

    context 'an example with no name' do

      context 'because the name is nil' do

        let(:test_model) do
          model      = CukeLinter::ModelFactory.generate_example_model(parent_file_path: model_file_path)
          model.name = nil

          model
        end

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Example grouping has no name')
        end

      end

      context 'because the name is empty' do

        let(:test_model) do
          model      = CukeLinter::ModelFactory.generate_example_model(parent_file_path: model_file_path)
          model.name = ''

          model
        end

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Example grouping has no name')
        end

      end

    end

    context 'an example with a name' do

      let(:test_model) do
        model      = CukeLinter::ModelFactory.generate_example_model
        model.name = 'a name'

        model
      end

      it_should_behave_like 'a linter linting a good model'

    end


    context 'a non-example model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
