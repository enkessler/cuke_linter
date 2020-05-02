require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithTooManyStepsLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithTooManyStepsLinter')
  end

  describe 'linting' do

    %w[scenario outline].each do |model_type|

      context "with a #{model_type} that has too many steps" do

        let(:test_model) do
          model       = send("generate_#{model_type}_model", parent_file_path: model_file_path)
          model.steps = %i[step_1
                           step_2
                           step_3
                           step_4
                           step_5
                           step_6
                           step_7
                           step_8
                           step_9
                           step_10
                           step_11]

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to match(/^Test has too many steps. \d+ steps found \(max 10\)/)
        end

        it 'includes the number of steps found in the problem record' do
          step_count = test_model.steps.count
          result     = subject.lint(test_model)
          expect(result[:problem]).to eq("Test has too many steps. #{step_count} steps found (max 10).")

          test_model.steps << :another_step
          result = subject.lint(test_model)
          expect(result[:problem]).to eq("Test has too many steps. #{step_count + 1} steps found (max 10).")
        end

      end

      context "with a #{model_type} that does not have too many steps" do

        context 'because it has fewer than 10 steps' do

          let(:test_model) do
            model       = send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
            model.steps = [:step_1]

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              model       = send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.steps = []

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because its steps are nil' do

            let(:test_model) do
              model       = send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.steps = nil

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

      end


      describe 'configuration' do

        context 'with no configuration' do

          let(:default_step_threshhold) { 10 }

          context 'because configuration never happened' do

            let(:unconfigured_test_model) do
              model       = send("generate_#{model_type}_model")
              model.steps = []
              (default_step_threshhold + 1).times { model.steps << :a_step }

              model
            end

            it 'defaults to a step threshold of 10 steps' do
              result = subject.lint(unconfigured_test_model)

              expect(result[:problem])
                .to match(/^Test has too many steps. #{unconfigured_test_model.steps.count} steps found \(max 10\)/)
            end

          end

          context 'because configuration did not set a step threshold' do
            let(:configuration) { {} }
            let(:configured_test_model) do
              model       = send("generate_#{model_type}_model")
              model.steps = []
              (default_step_threshhold + 1).times { model.steps << :a_step }

              subject.configure(configuration)

              model
            end

            it 'defaults to a step threshold of 10 steps' do
              result = subject.lint(configured_test_model)

              expect(result[:problem])
                .to match(/^Test has too many steps. #{configured_test_model.steps.count} steps found \(max 10\)/)
            end

          end

        end


        context 'with configuration' do

          let(:step_threshhold) { 3 }
          let(:configuration) { { 'StepThreshold' => step_threshhold } }

          subject do
            linter = CukeLinter::TestWithTooManyStepsLinter.new
            linter.configure(configuration)
            linter
          end

          let(:test_model) do
            model       = send("generate_#{model_type}_model")
            model.steps = []
            (step_threshhold + 1).times { model.steps << :a_step }

            model
          end

          it 'the step threshold used is the configured value' do
            result = subject.lint(test_model)

            expect(result[:problem])
              .to match(/^Test has too many steps. #{test_model.steps.count} steps found \(max #{step_threshhold}\)/)
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
