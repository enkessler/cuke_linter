require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithNoVerificationStepLinter do

  let(:model_file_path) { 'some_file_path' }

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
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
              model.steps = []

              model
            end

            it_should_behave_like 'a linter linting a bad model'


            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("Test does not have a 'Then' step.")
            end

          end

          context 'because its steps are nil' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
              model.steps = nil

              model
            end

            it_should_behave_like 'a linter linting a bad model'


            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("Test does not have a 'Then' step.")
            end

          end

        end

        context 'because none of its steps is a verification step' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.steps = [CukeModeler::Step.new('* not a verification step')]

            model
          end

          it_should_behave_like 'a linter linting a bad model'


          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq("Test does not have a 'Then' step.")
          end

        end

      end

      context "with a #{model_type} that does have a verification step" do

        context 'that comes from its background' do

          let(:test_model) do
            model                         = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps                   = []
            background_model              = CukeModeler::Background.new
            background_model.steps        = [CukeModeler::Step.new('Then a verification step')]
            model.parent_model.background = background_model

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'that is part of itself' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new('Then a verification step')]

            model
          end

          it_should_behave_like 'a linter linting a good model'

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

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
