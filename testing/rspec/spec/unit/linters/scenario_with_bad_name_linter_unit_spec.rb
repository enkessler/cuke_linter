require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::ScenarioWithBadNameLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'

  it 'has a name' do
    expect(subject.name).to eq('ScenarioWithBadNameLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has a bad name" do

        context 'because its name contains test' do

          let(:test_model) do
            model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.name = 'Test models with bad names'

            model
          end

          it_should_behave_like 'a linter linting a bad model'


          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq('Prefer name your scenarios using "Given" and "When" rather than "test", "verify" or "check".')
          end

        end

        context 'because its name contains verification' do

          let(:test_model) do
            model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.name = 'vErIfIcAtIoN of models with bad names'

            model
          end

          it_should_behave_like 'a linter linting a bad model'


          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq('Prefer name your scenarios using "Given" and "When" rather than "test", "verify" or "check".')
          end

        end

        context 'because its name contains check' do

          let(:test_model) do
            model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.name = 'CHECK! models with bad names'

            model
          end

          it_should_behave_like 'a linter linting a bad model'


          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq('Prefer name your scenarios using "Given" and "When" rather than "test", "verify" or "check".')
          end

        end

      end


      context "with a #{model_type} that does have a name" do

        let(:test_model) do
          model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
          model.name = 'foo'

          model
        end

        it_should_behave_like 'a linter linting a good model'

      end

    end

    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end

end
