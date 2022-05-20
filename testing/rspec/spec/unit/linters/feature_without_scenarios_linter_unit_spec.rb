RSpec.describe CukeLinter::FeatureWithoutScenariosLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FeatureWithoutScenariosLinter')
  end

  describe 'linting' do

    context 'a feature with no tests' do

      context 'because the tests are empty' do

        let(:test_model) do
          model       = generate_feature_model(parent_file_path: model_file_path)
          model.tests = []

          model
        end

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature has no scenarios')
        end

      end

      context 'because the tests are nil' do

        let(:test_model) do
          model       = generate_feature_model(parent_file_path: model_file_path)
          model.tests = nil

          model
        end

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature has no scenarios')
        end

      end

      context 'and no nested tests' do

        context 'because it has no rules' do

          context 'because the rules are empty' do

            let(:test_model) do
              model       = generate_feature_model(parent_file_path: model_file_path)
              model.rules = []

              model
            end

            it_should_behave_like 'a linter linting a bad model'

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq('Feature has no scenarios')
            end

          end

          context 'because the rules are nil' do

            let(:test_model) do
              model       = generate_feature_model(parent_file_path: model_file_path)
              model.rules = nil

              model
            end

            it_should_behave_like 'a linter linting a bad model'

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq('Feature has no scenarios')
            end

          end

        end

        context 'because its rules have no tests' do

          context 'because the rule tests are empty' do

            let(:test_model) do
              gherkin = 'Feature:
                           Rule:'
              model       = generate_feature_model(source_text: gherkin, parent_file_path: model_file_path)
              model.rules.first.tests = []

              model
            end

            it_should_behave_like 'a linter linting a bad model'

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq('Feature has no scenarios')
            end

          end

          context 'because the rule tests are nil' do

            let(:test_model) do
              gherkin = 'Feature:
                           Rule:'
              model       = generate_feature_model(source_text: gherkin, parent_file_path: model_file_path)
              model.rules.first.tests = nil

              model
            end

            it_should_behave_like 'a linter linting a bad model'

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq('Feature has no scenarios')
            end

          end

        end

      end

    end

    context 'a feature with tests' do

      context 'with a scenario' do

        let(:test_model) do
          gherkin = 'Feature:

                     Scenario:'

          generate_feature_model(source_text: gherkin)
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'with an outline' do

        let(:test_model) do
          gherkin = 'Feature:

                     Scenario Outline:
                       * a step
                     Examples:
                       | param |'

          generate_feature_model(source_text: gherkin)
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'with a rule' do

        context 'that has a scenario' do

          let(:test_model) do
            gherkin = 'Feature:
                         Rule:
                           Scenario:'

            generate_feature_model(source_text: gherkin)
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'that has an outline' do

          let(:test_model) do
            gherkin = 'Feature:
                         Rule:
                           Scenario Outline:
                             * a step
                           Examples:
                             | param |'

            generate_feature_model(source_text: gherkin)
          end

          it_should_behave_like 'a linter linting a good model'

        end

      end

      context 'with multiple rules' do

        let(:test_model) do
          gherkin = 'Feature:
                         Rule:
                         Rule:
                           Scenario:
                         Rule:'

          generate_feature_model(source_text: gherkin)
        end

        it_should_behave_like 'a linter linting a good model'

      end

    end

    context 'a non-feature model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
