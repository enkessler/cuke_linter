require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestShouldUseBackgroundLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestShouldUseBackgroundLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that shares a first step with all other tests in the feature" do

        let(:test_model) do
          step_text     = 'the step'
          feature_model = generate_feature_model(parent_file_path: model_file_path,
                                                 source_text:      "Feature:
                                                                      Scenario:
                                                                        * #{step_text}
                                                                      Scenario Outline:
                                                                        * #{step_text}
                                                                      Examples:
                                                                        | param |
                                                                        | value |")

          model       = send("generate_#{model_type}_model")
          model.steps = [CukeModeler::Step.new("* #{step_text}")]

          model.parent_model = feature_model
          feature_model.tests << model

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Test shares steps with all other tests in feature. Use a background.')
        end

      end

      context 'with parameters that are not really parameters' do

        if (model_type == 'scenario')

          # Scenarios don't actually have parameters, even if they look like they do
          context 'because they are in scenarios' do

            let(:test_model) do
              step_text     = 'the not really <parameterized> step'
              feature_model = generate_feature_model(parent_file_path: model_file_path,
                                                     source_text:      "Feature:
                                                                          Scenario:
                                                                            * #{step_text}
                                                                          Scenario:
                                                                            * #{step_text}")

              model       = send("generate_#{model_type}_model")
              model.steps = [CukeModeler::Step.new("* #{step_text}")]

              model.parent_model = feature_model
              feature_model.tests << model

              model
            end

            it_should_behave_like 'a linter linting a bad model'


            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq('Test shares steps with all other tests in feature. Use a background.')
            end

          end

        end


        if model_type == 'outline'

          context 'because of extra whitespace' do

            let(:test_model) do
              # Whitespace is significant
              step_text     = "the step <    param_foo     >"
              feature_model = generate_feature_model(parent_file_path: model_file_path,
                                                     source_text:      "Feature:
                                                                          Scenario Outline:
                                                                            * #{step_text}
                                                                          Examples:
                                                                            | param_foo |
                                                                            | value     |
                                                                          Scenario Outline:
                                                                            * #{step_text}
                                                                          Examples:
                                                                            | param_foo |
                                                                            | value     |")

              model       = send("generate_#{model_type}_model")
              model.steps = [CukeModeler::Step.new("* #{step_text}")]

              model.parent_model = feature_model
              feature_model.tests << model

              model
            end

            it_should_behave_like 'a linter linting a bad model'


            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq('Test shares steps with all other tests in feature. Use a background.')
            end

          end

        end

      end


      context "with a #{model_type} that does not share a first step with all other tests in the feature" do

        context 'because the steps are different' do

          let(:test_model) do
            step_text     = 'the step'
            feature_model = generate_feature_model(source_text: "Feature:
                                                                   Scenario:
                                                                     * #{step_text}
                                                                   Scenario Outline:
                                                                     * #{step_text}
                                                                   Examples:
                                                                     | param |
                                                                     | value |")

            model       = send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new("* #{step_text} plus extra")]

            model.parent_model = feature_model
            feature_model.tests << model

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = generate_feature_model(source_text: "Feature:
                                                                     Scenario:
                                                                       * #{step_text}
                                                                     Scenario Outline:
                                                                       * #{step_text}
                                                                     Examples:
                                                                       | param |
                                                                       | value |")

              model       = send("generate_#{model_type}_model")
              model.steps = []

              model.parent_model = feature_model
              feature_model.tests << model

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because its steps are nil' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = generate_feature_model(source_text: "Feature:
                                                                     Scenario:
                                                                       * #{step_text}
                                                                     Scenario Outline:
                                                                       * #{step_text}
                                                                     Examples:
                                                                       | param |
                                                                       | value |")

              model       = send("generate_#{model_type}_model")
              model.steps = nil

              model.parent_model = feature_model
              feature_model.tests << model

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

        context 'because another test has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = generate_feature_model(source_text: "Feature:
                                                                     Scenario:
                                                                       * #{step_text}
                                                                     Scenario Outline:
                                                                       * #{step_text}
                                                                     Examples:
                                                                       | param |
                                                                       | value |")

              model       = send("generate_#{model_type}_model")
              model.steps = [CukeModeler::Step.new("* #{step_text}")]

              model.parent_model              = feature_model
              feature_model.tests.first.steps = []
              feature_model.tests << model

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because its steps are nil' do

            let(:test_model) do
              step_text     = 'the step'
              feature_model = generate_feature_model(source_text: "Feature:
                                                                     Scenario:
                                                                       * #{step_text}
                                                                     Scenario Outline:
                                                                       * #{step_text}
                                                                     Examples:
                                                                       | param |
                                                                       | value |")

              model       = send("generate_#{model_type}_model")
              model.steps = [CukeModeler::Step.new("* #{step_text}")]

              model.parent_model              = feature_model
              feature_model.tests.first.steps = nil
              feature_model.tests << model

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

        context 'because there are not other tests in the feature' do

          let(:test_model) do
            step_text     = 'the step'
            feature_model = generate_feature_model(source_text: 'Feature:')

            model       = send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new("* #{step_text}")]

            model.parent_model = feature_model
            feature_model.tests << model

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because its first step contains a parameter' do

          let(:test_model) do
            step_text     = 'the maybe <parameterized> step'
            feature_model = generate_feature_model(source_text: "Feature:
                                                                   Scenario:
                                                                     * #{step_text}
                                                                   Scenario Outline:
                                                                     * #{step_text}
                                                                   Examples:
                                                                     | parameterized |
                                                                     | value         |")

            model       = send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new("* #{step_text}")]

            model.parent_model = feature_model
            feature_model.tests << model

            model
          end

          it_should_behave_like 'a linter linting a good model'

          if model_type == 'outline'

            context 'even with a bunch of parameterized outlines' do

              context 'with a parameter in the text of the step' do

                let(:test_model) do
                  step_text     = 'the <parameterized> step'
                  feature_model = generate_feature_model(source_text: "Feature:
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | parameterized |
                                                                           | value         |
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | parameterized |
                                                                           | value         |")

                  model       = send("generate_#{model_type}_model")
                  model.steps = [CukeModeler::Step.new("* #{step_text}")]

                  model.parent_model = feature_model
                  feature_model.tests << model

                  model
                end

                it_should_behave_like 'a linter linting a good model'

              end

              context 'with a parameter in the table of the step' do

                let(:test_model) do
                  step_text     = "the step\n | <param_foo> |"
                  feature_model = generate_feature_model(source_text: "Feature:
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | param_foo |
                                                                           | value     |
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | param_foo |
                                                                           | value     |")

                  model       = send("generate_#{model_type}_model")
                  model.steps = [CukeModeler::Step.new("* #{step_text}")]

                  model.parent_model = feature_model
                  feature_model.tests << model

                  model
                end

                it_should_behave_like 'a linter linting a good model'

              end

              context 'with a parameter in the doc string of the step' do

                let(:test_model) do
                  step_text     = "the step\n \"\"\"\n <param_foo>\n \"\"\""
                  feature_model = generate_feature_model(source_text: "Feature:
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | param_foo |
                                                                           | value     |
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | param_foo |
                                                                           | value     |")

                  model       = send("generate_#{model_type}_model")
                  model.steps = [CukeModeler::Step.new("* #{step_text}")]

                  model.parent_model = feature_model
                  feature_model.tests << model

                  model
                end

                it_should_behave_like 'a linter linting a good model'

              end

              context 'with inconsistent parameter usage' do

                let(:test_model) do
                  step_text     = "the step <param_foo>"
                  feature_model = generate_feature_model(source_text: "Feature:
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | param_foo |
                                                                           | value     |
                                                                         Scenario Outline:
                                                                           * #{step_text}
                                                                         Examples:
                                                                           | param_bar |
                                                                           | value     |
                                                                         Examples:
                                                                           | param_foo |
                                                                           | value     |")

                  model       = send("generate_#{model_type}_model")
                  model.steps = [CukeModeler::Step.new("* #{step_text}")]

                  model.parent_model = feature_model
                  feature_model.tests << model

                  model
                end

                it_should_behave_like 'a linter linting a good model'

              end

              # TODO: do outline parameters even get substituted in the doc string type?
            end

          end

        end

      end

    end

    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
