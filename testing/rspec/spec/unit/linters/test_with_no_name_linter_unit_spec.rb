require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithNoNameLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithNoNameLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has no name" do

        context 'because its name is empty' do

          let(:test_model) do
            model      = send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.name = ''

            model
          end

          it_should_behave_like 'a linter linting a bad model'


          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq('Test does not have a name.')
          end

        end

        context 'because its name is nil' do

          let(:test_model) do
            model      = send("generate_#{model_type}_model", parent_file_path: model_file_path)
            model.name = nil

            model
          end

          it_should_behave_like 'a linter linting a bad model'


          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to eq('Test does not have a name.')
          end

        end

      end

      context "with a #{model_type} that does have a name" do

        let(:test_model) do
          model      = send("generate_#{model_type}_model")
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
