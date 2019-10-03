require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithSetupStepAfterActionStepLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithSetupStepAfterActionStepLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has a setup step after an action step" do

        let(:test_model) do
          model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model",
                                                      parent_file_path: model_file_path)
          model.steps = [CukeModeler::Step.new('When a step'),
                         CukeModeler::Step.new('Given a step')]

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq("Test has 'Given' step after 'When' step.")
        end

      end

      context "with a #{model_type} that does not have a setup step after an action step" do

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

        context 'because its setup steps come before its action steps' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new('* a step')]

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

      end

      context "with a #{model_type} that has an associated background" do

        let(:test_model) do
          feature_model = CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                                          Background:
                                                                                            Given a step
                                                                                            When a step
                                                                                            Given a step
                                                                                            When a step')

          model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
          model.steps = [CukeModeler::Step.new('Given a step')]

          model.parent_model = feature_model
          feature_model.tests << model

          model
        end

        it 'does not consider those steps when linting' do
          expect(subject.lint(test_model)).to eq(nil)
        end

      end

    end


    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
