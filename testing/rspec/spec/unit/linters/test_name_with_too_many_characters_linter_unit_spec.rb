RSpec.describe CukeLinter::TestNameWithTooManyCharactersLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'

  it 'has a name' do
    expect(subject.name).to eq('TestNameWithTooManyCharactersLinter')
  end

  describe 'linting' do

    let(:default_character_threshold) { 80 }

    %w[scenario outline].each do |model_type|

      context "with a #{model_type} that has too long name" do

        context 'when the scenario name is too long' do

          let(:test_model) do
            scenario_name = 'x' * (default_character_threshold + 1)
            model         = send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.name    = scenario_name

            model
          end

          it_should_behave_like 'a linter linting a bad model'

          it 'reports a problem' do
            result = subject.lint(test_model)

            expect(result[:problem])
              .to match(/^Scenario name is too long. \d+ characters found \(max #{default_character_threshold}\)/)
          end

          it 'includes the number of characters found in the problem record' do
            character_count = test_model.name.length
            result = subject.lint(test_model)
            expect(result[:problem])
              .to eq("Scenario name is too long. #{character_count} characters found (max 80)")

            test_model.name += 'x'
            result = subject.lint(test_model)
            expect(result[:problem])
              .to eq("Scenario name is too long. #{character_count + 1} characters found (max 80)")
          end

        end

      end

      context 'when the scenario name is the maximum length' do

        let(:test_model) do
          scenario_name = 'x' * default_character_threshold
          model         = send("generate_#{model_type}_model")
          model.name    = scenario_name

          model
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'when the scenario name is below the maximum length' do

        let(:test_model) do
          scenario_name = 'x' * (default_character_threshold - 1)
          model         = send("generate_#{model_type}_model")
          model.name    = scenario_name

          model
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'when the scenario name has no text' do

        let(:test_model) do
          model = send("generate_#{model_type}_model")
          model.name = nil

          model
        end

        it_should_behave_like 'a linter linting a good model'

      end

      describe 'configuration' do

        context 'with no configuration' do

          context 'because configuration never happened' do

            let(:default_model) do
              scenario_name = 'x' * (default_character_threshold + 1)
              model         = send("generate_#{model_type}_model")
              model.name    = scenario_name

              model
            end

            it 'defaults to a maximum of 80 characters' do
              result = subject.lint(default_model)

              expect(result[:problem]).to match(/^Scenario name is too long. \d+ characters found \(max 80\)/)
            end

          end

          context 'because configuration did not set a test name threshold' do
            let(:configuration) { {} }
            let(:configured_model) do
              subject.configure(configuration)
              scenario_name = 'x' * (default_character_threshold + 1)
              model         = send("generate_#{model_type}_model")
              model.name    = scenario_name

              model
            end

            it 'defaults to a maximum of 80 characters' do
              result = subject.lint(configured_model)

              expect(result[:problem]).to match(/^Scenario name is too long. \d+ characters found \(max 80\)/)
            end

          end

        end

        context 'when configured' do
          let(:character_threshold) { 10 }
          let(:configuration) { { 'TestNameLengthThreshold' => character_threshold } }

          subject do
            linter = CukeLinter::TestNameWithTooManyCharactersLinter.new
            linter.configure(configuration)
            linter
          end

          let(:test_model) do
            scenario_name = 'x' * (character_threshold + 1)
            model         = send("generate_#{model_type}_model")
            model.name    = scenario_name

            model
          end

          it 'uses the maximum character length provided by configuration' do
            result = subject.lint(test_model)

            expect(result[:problem])
              .to match(/^Scenario name is too long. \d+ characters found \(max #{character_threshold}\)/)
          end

        end

      end

    end

    context 'a non-scenario model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end

end
