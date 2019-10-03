require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithActionStepAsFinalStepLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithActionStepAsFinalStepLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has an action step as its final step" do

        let(:test_model) do
          model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
          model.steps = [CukeModeler::Step.new('Given a step'),
                         CukeModeler::Step.new('When a step')]

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq("Test has 'When' as the final step.")
        end

      end

      context "with a #{model_type} that does not have an action step as its final step" do

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.steps = []

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because its steps are nil' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.steps = nil

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

        context 'because its final step is not an action step' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new('Then a step')]

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

      end

    end


    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
