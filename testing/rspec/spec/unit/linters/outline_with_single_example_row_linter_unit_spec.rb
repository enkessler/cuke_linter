require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::OutlineWithSingleExampleRowLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('OutlineWithSingleExampleRowLinter')
  end

  describe 'linting' do

    context 'an outline with only one example row' do

      context 'with only one example set' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param |
                       | value |'

          generate_outline_model(parent_file_path: model_file_path,
                                 source_text:      gherkin)
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Outline has only one example row')
        end

      end

      context 'with multiple example sets' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param |
                     Examples:
                       | param |
                       | value |'

          generate_outline_model(parent_file_path: model_file_path,
                                 source_text:      gherkin)
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Outline has only one example row')
        end

      end

    end

    context 'an outline with more than one example row' do

      context 'with only one example set' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param   |
                       | value 1 |
                       | value 2 |'

          generate_outline_model(source_text: gherkin)
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'with multiple example sets' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param   |
                       | value 1 |
                     Examples:
                       | param   |
                       | value 1 |'

          generate_outline_model(source_text: gherkin)
        end

        it_should_behave_like 'a linter linting a good model'

      end

    end

    context 'an outline with no example rows' do

      context 'because it has no example sets' do

        context 'because its examples are nil' do

          let(:test_model) do
            model          = generate_outline_model
            model.examples = nil

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because its examples are empty' do
          let(:test_model) do
            model          = generate_outline_model
            model.examples = []

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

      end

      context 'with only one example set' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param |'

          generate_outline_model(source_text: gherkin)
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'with multiple example sets' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param |
                     Examples:
                       | param |'

          generate_outline_model(source_text: gherkin)
        end

        it_should_behave_like 'a linter linting a good model'

      end

    end

    context 'a non-outline model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
