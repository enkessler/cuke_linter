require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithTooManyStepsLinter do

  let(:good_data) do
    model       = CukeLinter::ModelFactory.generate_scenario_model
    model.steps = [:step_1]

    model
  end

  let(:bad_data) do
    model       = CukeLinter::ModelFactory.generate_scenario_model
    model.steps = [:step_1,
                   :step_2,
                   :step_3,
                   :step_4,
                   :step_5,
                   :step_6,
                   :step_7,
                   :step_8,
                   :step_9,
                   :step_10,
                   :step_11]

    model
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithTooManyStepsLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has too many steps" do

        let(:test_model) do
          model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
          model.steps = [:step_1,
                         :step_2,
                         :step_3,
                         :step_4,
                         :step_5,
                         :step_6,
                         :step_7,
                         :step_8,
                         :step_9,
                         :step_10,
                         :step_11]

          model
        end

        it 'records a problem' do
          results = subject.lint(test_model)

          expect(results.first[:problem]).to match(/^Test has too many steps. \d+ steps found \(max 10\)/)
        end

        it 'records the location of the problem' do
          test_model.source_line = 1
          results                = subject.lint(test_model)
          expect(results.first[:location]).to eq('path_to_file:1')

          test_model.source_line = 3
          results                = subject.lint(test_model)
          expect(results.first[:location]).to eq('path_to_file:3')
        end

        it 'includes the number of steps found in the problem record' do
          step_count = test_model.steps.count
          results    = subject.lint(test_model)
          expect(results.first[:problem]).to eq("Test has too many steps. #{step_count} steps found (max 10)")

          test_model.steps << :another_step
          results = subject.lint(test_model)
          expect(results.first[:problem]).to eq("Test has too many steps. #{step_count + 1} steps found (max 10)")
        end

      end

      context "with a #{model_type} that does not have too many steps" do

        context 'because it has fewer than 10 steps' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
            model.steps = [:step_1]

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq([])
          end

        end

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.steps = []

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq([])
            end

          end

          context 'because its steps are nil' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.steps = nil

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq([])
            end

          end

        end

      end

    end

    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it 'returns an empty set of results' do
        results = subject.lint(test_model)

        expect(results).to eq([])
      end

    end
  end
end
