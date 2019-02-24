require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::FeatureWithoutScenariosLinter do

  let(:good_data) do
    model       = CukeLinter::ModelFactory.generate_feature_model
    model.tests = ['totally_a_test']

    model
  end

  let(:bad_data) do
    model       = CukeLinter::ModelFactory.generate_feature_model
    model.tests = []

    model
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FeatureWithoutScenariosLinter')
  end

  describe 'linting' do

    context 'a feature with no scenarios' do

      let(:test_model_with_empty_scenarios) do
        model       = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
        model.tests = []

        model
      end

      let(:test_model_with_nil_scenarios) do
        model       = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
        model.tests = nil

        model
      end

      it 'records a problem' do
        results = subject.lint(test_model_with_empty_scenarios)

        expect(results.first[:problem]).to eq('Feature has no scenarios')

        results = subject.lint(test_model_with_nil_scenarios)

        expect(results.first[:problem]).to eq('Feature has no scenarios')
      end

      it 'records the location of the problem' do
        model_1             = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
        model_1.tests       = []
        model_1.source_line = 1
        model_2             = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
        model_2.tests       = []
        model_2.source_line = 3

        results = subject.lint(model_1)
        expect(results.first[:location]).to eq('path_to_file:1')

        results = subject.lint(model_2)
        expect(results.first[:location]).to eq('path_to_file:3')
      end

    end

    context 'a feature with scenarios' do

      context 'with a scenario' do

        let(:test_model) do
          gherkin = 'Feature:

                     Scenario:'

          CukeLinter::ModelFactory.generate_feature_model(source_text: gherkin)
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq([])
        end

      end

      context 'with an outline' do

        let(:test_model) do
          gherkin = 'Feature:

                     Scenario Outline:
                       * a step
                     Examples:
                       | param |'

          CukeLinter::ModelFactory.generate_feature_model(source_text: gherkin)
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq([])
        end

      end

    end

    context 'a non-feature model' do

      it 'returns an empty set of results' do
        results = subject.lint(CukeModeler::Model.new)

        expect(results).to eq([])
      end

    end
  end
end
