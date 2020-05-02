require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithSetupStepAsFinalStepLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithSetupStepAsFinalStepLinter')
  end

  describe 'linting' do

    %w[scenario outline].each do |model_type|

      context "with a #{model_type} that has a setup step as its final step" do

        let(:test_model) do
          model       = send("generate_#{model_type}_model", parent_file_path: model_file_path)
          model.steps = [CukeModeler::Step.new('When a step'),
                         CukeModeler::Step.new('Given a step')]

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq("Test has 'Given' as the final step.")
        end

      end

      context "with a #{model_type} that does not have a setup step as its final step" do

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              model       = send("generate_#{model_type}_model")
              model.steps = []

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because its steps are nil' do

            let(:test_model) do
              model       = send("generate_#{model_type}_model")
              model.steps = nil

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

        context 'because its final step is not a setup step' do

          let(:test_model) do
            model       = send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new('Then a step')]

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

      end

    end

    describe 'configuration' do

      let(:test_model) do
        generate_scenario_model(source_text: 'Scenario:
                                                * a step')
      end

      context 'with configuration' do

        before(:each) do
          subject.configure(configuration)
        end

        context "with a configured 'Given' keyword" do

          let(:given_keyword) { 'Foo' }
          let(:configuration) { { 'Given' => given_keyword } }

          it "uses the configured 'Given' keyword" do
            test_model.steps.last.keyword = given_keyword

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

      end

      context 'without configuration' do

        context 'because configuration never happened' do

          it "uses the default 'Given' keyword" do
            test_model.steps.last.keyword = CukeLinter::DEFAULT_GIVEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

        context "because configuration did not set a 'Given' keyword" do

          before(:each) do
            subject.configure(configuration)
          end

          let(:configuration) { {} }

          it "uses the default 'Given' keyword" do
            test_model.steps.last.keyword = CukeLinter::DEFAULT_GIVEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to_not be_nil
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
