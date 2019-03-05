require_relative '../../../../environments/rspec_env'


RSpec.describe CukeLinter::OutlineWithSingleExampleRowLinter do

  let(:good_data) do
    outline_text = 'Scenario Outline:
                      * a step
                    Examples:
                      | param   |
                      | value 1 |
                      | value 2 |'

    CukeLinter::ModelFactory.generate_outline_model(source_text: outline_text)
  end

  let(:bad_data) do
    outline_text = 'Scenario Outline:
                      * a step
                    Examples:
                      | param   |
                      | value 1 |'

    CukeLinter::ModelFactory.generate_outline_model(source_text: outline_text)
  end


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

          CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin)
        end

        it 'records a problem' do
          results = subject.lint(test_model)

          expect(results.first[:problem]).to eq('Outline has only one example row')
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

          CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin)
        end

        it 'records a problem' do
          results = subject.lint(test_model)

          expect(results.first[:problem]).to eq('Outline has only one example row')
        end

      end


      it 'records the location of the problem' do
        gherkin = 'Scenario Outline:
                     * a step
                   Examples:
                     | param |
                     | value |'

        model_1 = CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin, parent_file_path: 'path_to_file')
        model_2 = CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin, parent_file_path: 'path_to_file')

        model_1.source_line = 1
        model_2.source_line = 3

        results = subject.lint(model_1)
        expect(results.first[:location]).to eq('path_to_file:1')

        results = subject.lint(model_2)
        expect(results.first[:location]).to eq('path_to_file:3')
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

          CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin)
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq([])
        end

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

          CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin)
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq([])
        end

      end

    end

    context 'an outline with no example rows' do

      context 'because it has no example sets' do

        context 'because its examples are nil' do

          let(:test_model) do
            model          = CukeLinter::ModelFactory.generate_outline_model
            model.examples = nil

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq([])
          end

        end

        context 'because its examples are empty' do
          let(:test_model) do
            model          = CukeLinter::ModelFactory.generate_outline_model
            model.examples = []

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq([])
          end

        end

      end

      context 'with only one example set' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param |'

          CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin)
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq([])
        end

      end

      context 'with multiple example sets' do

        let(:test_model) do
          gherkin = 'Scenario Outline:
                       * a step
                     Examples:
                       | param |
                     Examples:
                       | param |'

          CukeLinter::ModelFactory.generate_outline_model(source_text: gherkin)
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq([])
        end

      end

    end

    context 'a non-outline model' do

      it 'returns an empty set of results' do
        results = subject.lint(CukeModeler::Model.new)

        expect(results).to eq([])
      end

    end
  end
end
