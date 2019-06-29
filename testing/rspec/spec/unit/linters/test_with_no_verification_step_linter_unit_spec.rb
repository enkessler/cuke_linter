require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithNoVerificationStepLinter do

  let(:good_data) do
    CukeLinter::ModelFactory.generate_scenario_model(source_text: 'Scenario:
                                                                     Then a verification step')
  end

  let(:bad_data) do
    CukeLinter::ModelFactory.generate_scenario_model(source_text: 'Scenario:
                                                                     * no verification step')
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithNoVerificationStepLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has no verification step" do

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.steps = []

              model
            end

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("Test does not have a 'Then' step.")
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

              expect(result[:problem]).to eq("Test does not have a 'Then' step.")
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

        context 'because none of its steps is a verification step' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
            model.steps = [CukeModeler::Step.new('* not a verification step')]

            model
          end

          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq("Test does not have a 'Then' step.")
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

      context "with a #{model_type} that does have a verification step" do

        let(:test_model) do
          model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
          model.steps = [CukeModeler::Step.new('Then a verification step')]

          model
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq(nil)
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
