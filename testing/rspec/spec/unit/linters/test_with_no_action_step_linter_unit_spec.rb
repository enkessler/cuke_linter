require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithNoActionStepLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithNoActionStepLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has no action step" do

        context 'because it has no steps' do

          context 'because its steps are empty' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
              model.steps = []

              model
            end

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("Test does not have a 'When' step.")
            end

            it_should_behave_like 'a linter linting a bad model'

          end

          context 'because its steps are nil' do

            let(:test_model) do
              model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
              model.steps = nil

              model
            end

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("Test does not have a 'When' step.")
            end

            it_should_behave_like 'a linter linting a bad model'

          end

        end

        context 'because none of its steps is an action step' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.steps = [CukeModeler::Step.new('* not an action step')]

            model
          end

          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq("Test does not have a 'When' step.")
          end

          it_should_behave_like 'a linter linting a bad model'

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

          it_should_behave_like 'a linter linting a good model'

        end

        context 'that is part of itself' do

          let(:test_model) do
            model       = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.steps = [CukeModeler::Step.new('When an action step')]

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


    describe 'configuration' do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_scenario_model(source_text: 'Scenario:
                                                                         When a step')
      end

      context 'with configuration' do

        before(:each) do
          subject.configure(configuration)
        end

        context "with a configured 'When' keyword" do

          let(:when_keyword) { 'Foo' }
          let(:configuration) { { 'When' => when_keyword } }

          it "uses the configured 'When' keyword" do
            test_model.steps.first.keyword = 'When'

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

      end

      context 'without configuration' do

        context 'because configuration never happened' do

          it "uses the default 'When' keyword" do
            test_model.steps.first.keyword = CukeLinter::DEFAULT_WHEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to be_nil
          end

        end

        context "because configuration did not set a 'When' keyword" do

          before(:each) do
            subject.configure(configuration)
          end

          let(:configuration) { {} }

          it "uses the default 'When' keyword" do
            test_model.steps.last.keyword = CukeLinter::DEFAULT_WHEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to be_nil
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
