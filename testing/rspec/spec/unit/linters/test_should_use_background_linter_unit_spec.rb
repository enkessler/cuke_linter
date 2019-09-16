require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestShouldUseBackgroundLinter do

  let(:good_data) do
    parent_model = CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                                   Scenario:
                                                                                     * a step
                                                                                   Scenario:
                                                                                     * a different step')
    parent_model.tests.first
  end

  let(:bad_data) do
    parent_model = CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                                   Scenario:
                                                                                     * the same step
                                                                                   Scenario:
                                                                                     * the same step')
    parent_model.tests.first
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestShouldUseBackgroundLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that shares a first step with all other tests in the feature" do

        let(:test_model) do
          step_text     = 'the step'
          feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: "Feature:
                                                                                           Scenario:
                                                                                             * #{step_text}
                                                                                           Scenario Outline:
                                                                                             * #{step_text}
                                                                                           Examples:
                                                                                             | param |
                                                                                             | value |")

          model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
          model.steps = [CukeModeler::Step.new("* #{step_text}")]

          model.parent_model = feature_model
          feature_model.tests << model

          model
        end

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Test shares steps with all other tests in feature. Use a background.')
        end

        it 'records the location of the problem' do
          test_model.source_line = 1
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:1')

          test_model.source_line = 3
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:3')
        end

      end

      context "with a #{model_type} that does not share a first step with all other tests in the feature" do

        context 'because the steps are different' do

          let(:test_model) do
            step_text     = 'the step'
            feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: "Feature:
                                                                                           Scenario:
                                                                                             * #{step_text}
                                                                                           Scenario Outline:
                                                                                             * #{step_text}
                                                                                           Examples:
                                                                                             | param |
                                                                                             | value |")

            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new("* #{step_text} plus extra")]

            model.parent_model = feature_model
            feature_model.tests << model

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq(nil)
          end

        end

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: "Feature:
                                                                                           Scenario:
                                                                                             * #{step_text}
                                                                                           Scenario Outline:
                                                                                             * #{step_text}
                                                                                           Examples:
                                                                                             | param |
                                                                                             | value |")

              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.steps = []

              model.parent_model = feature_model
              feature_model.tests << model

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq(nil)
            end

          end

          context 'because its steps are nil' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: "Feature:
                                                                                           Scenario:
                                                                                             * #{step_text}
                                                                                           Scenario Outline:
                                                                                             * #{step_text}
                                                                                           Examples:
                                                                                             | param |
                                                                                             | value |")

              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.steps = nil

              model.parent_model = feature_model
              feature_model.tests << model

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq(nil)
            end

          end

        end

        context 'because another test has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: "Feature:
                                                                                           Scenario:
                                                                                             * #{step_text}
                                                                                           Scenario Outline:
                                                                                             * #{step_text}
                                                                                           Examples:
                                                                                             | param |
                                                                                             | value |")

              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.steps = [CukeModeler::Step.new("* #{step_text}")]

              model.parent_model              = feature_model
              feature_model.tests.first.steps = []
              feature_model.tests << model

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq(nil)
            end

          end

          context 'because its steps are nil' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: "Feature:
                                                                                           Scenario:
                                                                                             * #{step_text}
                                                                                           Scenario Outline:
                                                                                             * #{step_text}
                                                                                           Examples:
                                                                                             | param |
                                                                                             | value |")

              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.steps = [CukeModeler::Step.new("* #{step_text}")]

              model.parent_model              = feature_model
              feature_model.tests.first.steps = nil
              feature_model.tests << model

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq(nil)
            end

          end

        end

        context 'because there are not other tests in the feature' do

          let(:test_model) do
            step_text     = 'the step'
            feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:')

            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new("* #{step_text}")]

            model.parent_model = feature_model
            feature_model.tests << model

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq(nil)
          end

        end

      end

    end

    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it 'returns no result' do
        result = subject.lint(test_model)

        expect(result).to eq(nil)
      end

    end
  end
end
