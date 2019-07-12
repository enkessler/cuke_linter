require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithNoActionStepLinter do

  let(:good_data) do
    CukeLinter::ModelFactory.generate_scenario_model(source_text: 'Scenario:
                                                                     When an action step')
  end

  let(:bad_data) do
    CukeLinter::ModelFactory.generate_scenario_model(source_text: 'Scenario:
                                                                     * no action step')
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithNoActionStepLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has no action step" do

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.steps = []

              model
            end

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("Test does not have a 'When' step.")
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

          context 'because its steps are nil' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.steps = nil

              model
            end

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("Test does not have a 'When' step.")
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

        end

        context 'because none of its steps is an action step' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
            model.steps = [CukeModeler::Step.new('* not an action step')]

            model
          end

          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq("Test does not have a 'When' step.")
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

      end

      context "with a #{model_type} that does have an action step" do

        context 'that comes from its background' do

          let(:test_model) do
            model                         = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps                   = []
            background_model              = CukeModeler::Background.new
            background_model.steps        = [CukeModeler::Step.new('When an action step')]
            model.parent_model.background = background_model

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq(nil)
          end

        end

        context 'that is part of itself' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new('When an action step')]

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq(nil)
          end

        end

      end

    end

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has a related background" do

        let(:test_model) do
          model                         = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
          model.parent_model.background = background_model

          model
        end

        context 'that has no background steps' do
          context 'because its steps are empty' do

            let(:background_model) do
              model       = CukeModeler::Background.new
              model.steps = []

              model
            end

            it 'can handle it' do
              expect { subject.lint(test_model) }.to_not raise_error
            end

          end

          context 'because its steps are nil' do

            let(:background_model) do
              model       = CukeModeler::Background.new
              model.steps = nil

              model
            end

            it 'can handle it' do
              expect { subject.lint(test_model) }.to_not raise_error
            end

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
