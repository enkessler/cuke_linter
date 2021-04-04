RSpec.describe CukeLinter::FeatureWithoutDescriptionLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FeatureWithoutDescriptionLinter')
  end

  describe 'linting' do

    context 'a feature with no description' do

      context 'because the description is empty' do

        let(:test_model) do
          model             = generate_feature_model(parent_file_path: model_file_path)
          model.description = ''

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature has no description')
        end

      end

      context 'because the description is nil' do

        let(:test_model) do
          model             = generate_feature_model(parent_file_path: model_file_path)
          model.description = nil

          model
        end

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature has no description')
        end

        it_should_behave_like 'a linter linting a bad model'

      end
    end

    context 'a feature with a description' do

      let(:test_model) do
        model_source = "Feature:\n  This feature has a description"
        generate_feature_model(source_text:      model_source,
                               parent_file_path: 'path_to_file')
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'a non-feature model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end
end
