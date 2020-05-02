require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::FeatureFileWithMismatchedNameLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FeatureFileWithMismatchedNameLinter')
  end

  describe 'linting' do

    let(:test_model) do
      feature_model = generate_feature_model(parent_file_path: model_file_path,
                                             source_text:      "Feature: #{model_feature_name}")

      feature_model.parent_model
    end


    context 'with a feature file model that has mismatched feature name' do

      let(:model_file_path) { 'foo.feature' }
      let(:model_feature_name) { 'Bar' }

      it_should_behave_like 'a linter linting a bad model'

      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to eq('Feature file name does not match feature name.')
      end

    end

    context 'with a feature file model that does not have a mismatched feature name' do

      context 'with a file name that has caps' do
        let(:model_file_path) { 'Name With Caps.feature' }
        let(:model_feature_name) { 'name with caps' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a feature name that has caps' do
        let(:model_file_path) { 'name with caps.feature' }
        let(:model_feature_name) { 'Name With Caps' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a file name that has underscores' do
        let(:model_file_path) { 'name_with_underscores.feature' }
        let(:model_feature_name) { 'name with underscores' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a feature name that has underscores' do
        let(:model_file_path) { 'name with underscores.feature' }
        let(:model_feature_name) { 'name_with_underscores' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a file name that has spaces' do
        let(:model_file_path) { 'name with spaces.feature' }
        let(:model_feature_name) { 'namewithspaces' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a feature name that has spaces' do
        let(:model_file_path) { 'namewithspaces.feature' }
        let(:model_feature_name) { 'name with spaces' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a file name that has hyphens' do
        let(:model_file_path) { 'name-with-hyphens.feature' }
        let(:model_feature_name) { 'namewithhyphens' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a feature name that has hyphens' do
        let(:model_file_path) { 'namewithhyphens.feature' }
        let(:model_feature_name) { 'name-with-hyphens' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a file name that has mixed ignored characters' do
        let(:model_file_path) { '_namewith lotsOf-stuff.feature' }
        let(:model_feature_name) { 'namewithlotsofstuff' }

        it_should_behave_like 'a linter linting a good model'
      end

      context 'with a feature name that has mixed ignored characters' do
        let(:model_file_path) { 'namewithlotsofstuff.feature' }
        let(:model_feature_name) { '_namewith lotsOf-stuff' }

        it_should_behave_like 'a linter linting a good model'
      end

    end

    context 'a non-feature-file model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end

end
