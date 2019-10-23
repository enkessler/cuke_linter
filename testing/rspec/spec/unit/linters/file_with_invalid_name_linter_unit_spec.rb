require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::FileWithInvalidNameLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FileWithInvalidNameLinter')
  end

  describe 'linting' do

    it "only lints the file name" do
      test_model = CukeLinter::ModelFactory.generate_feature_file_model
      test_model.path = 'bad-directory/good_path.feature'

      expect(subject.lint(test_model)).to be_nil
    end

    context "with a feature_file_model that has an invalid file name" do

      let(:test_model) do
        model      = CukeLinter::ModelFactory.generate_feature_file_model

        model.path = model_file_path
        model
      end

      context 'because its file name is capitalized' do
        let(:model_file_path) { 'Terrible' }

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature files should be snake_cased.')
        end
      end

      context 'because its file name is camel-cased' do
        let(:model_file_path) { 'veryBad' }

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature files should be snake_cased.')
        end
      end

      context 'because its file name contains whitespace' do
        let(:model_file_path) { 'stop this' }

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature files should be snake_cased.')
        end
      end

      context 'because its file name is hyphenated' do
        let(:model_file_path) { 'the-worst-path' }

        it_should_behave_like 'a linter linting a bad model'

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature files should be snake_cased.')
        end
      end

    end

    context "with a feature_file that does have a valid file name" do

      let(:test_model) do
        model      = CukeLinter::ModelFactory.generate_feature_file_model

        model.path = 'very_good_path'
        model
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end

end
